using Toybox.Application;
using Toybox.Communications;
import Toybox.Lang;
using Toybox.Time;
(:background)
class AlertRequest {
    var _done;
    var _location as Dictionary or Null;
    var _provider;
    var _requestStamp;
    var _gateStamp;
    var _queries as Array;
    var _index=0;
    var _aggregate=AlertLogic.NONE;
    var _uncertain=false;
    var _token="";
    var _busy=false;
    function initialize(done as Lang.Method) { _done=done;_queries=[]; }
    function start(manual) {
        var now=Time.now().value();_location=Config.location();_provider=Config.provider();
        var r=Cache.load(_location);
        if (_busy || !Cache.canRequest(r,now,manual)) { _done.invoke();return; }
        var gate=Application.Storage.getValue("requestGate");
        if (gate instanceof Dictionary && gate["until"] instanceof Number && gate["at"] instanceof Number && gate["until"]>now && gate["at"]<=now) { _done.invoke();return; }
        _token=Config.needsToken() ? Config.token() : "";
        if ((Config.needsToken() && _token.length()==0) || !_location["valid"] || (_provider!=0 && !_location["uaSupported"])) {
            r["failed"]=true;r["lease"]=0;r["next"]=now+Config.interval();
            r["error"]=!_location["valid"] ? "Open app to resolve location" : (_provider!=0 && !_location["uaSupported"]) ? "Location unsupported by API" : "Set token in Connect IQ";
            Cache.save(r);Cache.publish(r,_location,now);_done.invoke();return;
        }
        _queries=ApiProvider.queries(_provider,_location);_index=0;_aggregate=AlertLogic.NONE;_uncertain=false;
        // Retrying an interrupted request must not turn its visible UNKNOWN
        // back into CLEAR just by renewing the lease. Validation is required.
        if (r["lease"]>0 && r["lease"]<=now) { r["failed"]=true; }
        _busy=true;_requestStamp=now;
        var sequence=Application.Storage.getValue("requestSequence");
        if (!(sequence instanceof Number)) { sequence=0; }
        _gateStamp=sequence+1;Application.Storage.setValue("requestSequence",_gateStamp);
        Application.Storage.setValue("requestGate",{"at"=>now,"until"=>now+60,"sequence"=>_gateStamp});
        r["request"]=now;r["sequence"]=_gateStamp;r["lease"]=now+60;
        // Keep the last validated result and its original success timestamp
        // while fetching. Unknown/failed/stale caches remain visibly so. Only
        // a validated response clears failure; lease expiry covers interruption.
        r["error"]="Refreshing...";Cache.save(r);Cache.publish(r,_location,now);
        next();
    }
    function next() {
        var now=Time.now().value();var r=Cache.load(_location);
        r["lease"]=now+60;Cache.save(r);
        Application.Storage.setValue("requestGate",{"at"=>now,"until"=>now+60,"sequence"=>_gateStamp});
        try { send(_token); } catch(e) { response(-1,null); }
    }
    function send(token) {
        var handler=responseHandler();
        Communications.makeWebRequest(ApiProvider.url(_provider,_queries[_index]),null,
            {:method=>Communications.HTTP_REQUEST_METHOD_GET,:headers=>ApiProvider.headers(_provider,token),
             :responseType=>Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON},handler.method(:onReceive));
    }
    function responseHandler() { return new AlertResponse(self,_gateStamp,_index); }
    function webResponse(code, data, sequence, index) as Void {
        if (!_busy || sequence!=_gateStamp || index!=_index) { return; }
        response(code,data);
    }
    function response(code, data) as Void {
        var now=Time.now().value();var current=Config.location();var r=Cache.load(current);
        if (!_busy || Config.provider()!=_provider || current["uid"]!=_location["uid"] || r["sequence"]!=_gateStamp || r["request"]!=_requestStamp) { _busy=false;_token="";_done.invoke();return; }
        var value=AlertLogic.UNKNOWN;
        if (code==200) {
            try { value=_provider==0 ? AlertLogic.parse(data,current) : ApiProvider.parse(data,current,_queries[_index]); }
            catch(e) { value=AlertLogic.UNKNOWN; }
        }
        if (code!=200) { Cache.failure(r,code,now);finish(r,current,now);return; }
        if (value==AlertLogic.RED) { _aggregate=AlertLogic.RED; }
        else if (value==AlertLogic.UNKNOWN) { _uncertain=true; }
        else if (value==AlertLogic.YELLOW && _aggregate!=AlertLogic.RED) { _aggregate=AlertLogic.YELLOW; }
        _index+=1;
        // Known RED is maximal: no more requests can reduce this warning.
        if (_aggregate!=AlertLogic.RED && _index<_queries.size()) { next();return; }
        if (_uncertain && _aggregate!=AlertLogic.RED) { Cache.failure(r,-400,now); }
        else { Cache.success(r,_aggregate,now); }
        finish(r,current,now);
    }
    function finish(r as Dictionary, location as Dictionary, now) {
        _busy=false;_token="";Cache.save(r);Cache.publish(r,location,now);_done.invoke();
    }
}

// Keep correlation in a bound callback object, not makeWebRequest's :context.
// Physical firmware can deliver two arguments even with :context populated,
// including immediate transport errors. The two-argument API works in either
// case and the captured sequence/index still rejects old or duplicate replies.
(:background)
class AlertResponse {
    var _request;
    var _sequence;
    var _index;
    function initialize(request, sequence, index) {
        _request=request;_sequence=sequence;_index=index;
    }
    // JSON root arrays arrive dynamically despite the SDK callback typedef.
    function onReceive(code as Number, data as Dictionary or String or Null) as Void {
        _request.webResponse(code,data,_sequence,_index);
    }
}
