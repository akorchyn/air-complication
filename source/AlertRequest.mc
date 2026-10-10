using Toybox.Application;
using Toybox.Communications;
import Toybox.Lang;
using Toybox.Time;
using Toybox.System;
(:background)
class AlertRequest {
    var _done;
    var _location as Dictionary or Null;
    var _requestStamp;
    var _gateStamp;
    var _busy=false;
    function initialize(done as Lang.Method) { _done=done; }
    function start(manual) {
        var now=Time.now().value();
        _location=Config.location();
        var r=Cache.load(_location);
        if (_busy || !Cache.canRequest(r,now,manual)) { _done.invoke();return; }
        var gate=Application.Storage.getValue("requestGate");
        if (gate instanceof Dictionary && gate["until"] instanceof Number && gate["at"] instanceof Number && gate["until"]>now && gate["at"]<=now) { _done.invoke();return; }
        var token=Config.token();
        if (token.length()==0 || !_location["valid"]) {
            r["failed"]=true;r["lease"]=0;r["next"]=now+Config.interval();
            r["error"]=token.length()==0 ? "Configure API token" : "Open app to resolve UID";
            Cache.save(r);Cache.publish(r,_location,now);_done.invoke();return;
        }
        _busy=true;_requestStamp=now;
        var sequence=Application.Storage.getValue("requestSequence");
        if (!(sequence instanceof Number)) { sequence=0; }
        _gateStamp=sequence+1;Application.Storage.setValue("requestSequence",_gateStamp);
        Application.Storage.setValue("requestGate",{"at"=>now,"until"=>now+60,"sequence"=>_gateStamp});
        r["request"]=now;r["lease"]=now+60;
        // Fail closed BEFORE asynchronous allocation/networking. If the OS kills
        // this service, a previous CLEAR is already invalidated.
        r["failed"]=true;r["error"]="Refreshing...";Cache.save(r);Cache.publish(r,_location,now);
        try {
            send(token);
        } catch (e) {
            // Do not stringify exceptions: they can contain request parameters.
            response(-1,null);
        }
    }
    function send(token) {
        Communications.makeWebRequest("https://api.alerts.in.ua/v1/alerts/active.json",null,
                {:method=>Communications.HTTP_REQUEST_METHOD_GET,
                 :headers=>{"Authorization"=>"Bearer "+token,"Accept"=>"application/json"},
                 :responseType=>Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON},method(:response));
    }
    function response(code as Lang.Number, data as Lang.Dictionary or Lang.String or Null) as Void {
        _busy=false;
        var now=Time.now().value();
        var current=Config.location();
        var r=Cache.load(current);
        // Settings may change while the phone request is in flight.
        if (current["uid"]==_location["uid"] && current["oblast"]==_location["oblast"] && current["raion"]==_location["raion"] && r["request"]==_requestStamp) {
            try { Cache.accept(r,code,data,current,now); }
            catch (e) { Cache.failure(r,-400,now); }
            Cache.save(r);Cache.publish(r,current,now);
        }
        _done.invoke();
    }
}
