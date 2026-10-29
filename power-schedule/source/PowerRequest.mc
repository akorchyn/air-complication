using Toybox.Application;
using Toybox.Communications;
using Toybox.Time;
import Toybox.Lang;
(:background)
class PowerRequest {
    var _done;var _busy=false;var _sequence=0;var _key="";
    function initialize(done as Lang.Method) { _done=done; }
    function start(manual) {
        var now=Time.now().value();var r=PowerCache.load();
        var gate=Application.Storage.getValue("powerGate");
        if(_busy || r["lease"]>now || (now>=r["request"] && now-r["request"]<60) || (r["failures"]>0 && r["next"]>now) || (!manual && r["next"]>now) ||
            (gate instanceof Dictionary && gate["at"] instanceof Number && gate["until"] instanceof Number && gate["at"]<=now && gate["until"]>now)) { _done.invoke();return; }
        if(!PowerConfig.ready()) { r["error"]="Set adapter URL in Connect IQ";PowerCache.save(r);PowerCache.publish(r,now);_done.invoke();return; }
        var seq=Application.Storage.getValue("powerSequence");if(!(seq instanceof Number)) { seq=0; }
        _sequence=seq+1;Application.Storage.setValue("powerSequence",_sequence);
        Application.Storage.setValue("powerGate",{"at"=>now,"until"=>now+60});
        if(r["lease"]>0 && r["lease"]<=now) { r["failed"]=true; }
        _key=PowerConfig.key();_busy=true;
        r["sequence"]=_sequence;r["request"]=now;r["lease"]=now+60;r["error"]="Refreshing...";
        PowerCache.save(r);PowerCache.publish(r,now);
        try { send(); } catch(e) { receive(-1,null,_sequence); }
    }
    function send() {
        var headers={"Accept"=>"application/json"};var token=PowerConfig.string("adapterToken");
        if(token.length()>0) { headers["Authorization"]="Bearer "+token; }
        var callback=new PowerResponse(self,_sequence);
        Communications.makeWebRequest(PowerConfig.url(),null,{:method=>Communications.HTTP_REQUEST_METHOD_GET,:headers=>headers,:responseType=>Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON},callback.method(:onReceive));
    }
    function receive(code, data, sequence) as Void {
        if(!_busy || sequence!=_sequence) { return; }
        var r=PowerCache.load();var now=Time.now().value();
        _busy=false;
        if(!_key.equals(PowerConfig.key()) || r["sequence"]!=sequence) { _done.invoke();return; }
        if(code==200 && PowerLogic.valid(data,now)) {
            r["data"]=data;r["fetched"]=now;r["failed"]=false;r["failures"]=0;r["lease"]=0;r["next"]=now+PowerConfig.interval();r["error"]="";
        } else { PowerCache.fail(r,code==200 ? -400 : code,now); }
        PowerCache.save(r);PowerCache.publish(r,now);_done.invoke();
    }
}
(:background)
class PowerResponse {
    var _owner;var _sequence;
    function initialize(owner, sequence) { _owner=owner;_sequence=sequence; }
    function onReceive(code as Number, data as Dictionary or String or Null) as Void { _owner.receive(code,data,_sequence); }
}
