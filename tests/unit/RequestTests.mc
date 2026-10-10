using Toybox.Application;
using Toybox.Time;
using Toybox.Test;
import Toybox.Lang;
// A controllable transport exercises the real request lifecycle and persistence.
class MockRequest extends AlertRequest {
 var sends=0;
 function initialize(done as Lang.Method) { AlertRequest.initialize(done); }
 function send(token) { sends+=1; }
}
class RequestObserver {
 var finished=0;
 function initialize() {}
 function done() as Void { finished+=1; }
}
function requestSetup() {
 resetTest();Application.Properties.setValue("apiToken","FIXTURE_ONLY");
 Application.Storage.deleteValue("requestGate");return new RequestObserver();
}
(:test)
function missing_token_avoids_network(logger) {
 var o=requestSetup();Application.Properties.setValue("apiToken","");
 var req=new MockRequest(o.method(:done));req.start(true);
 Test.assertEqual(req.sends,0);Test.assertEqual(o.finished,1);return true;
}
(:test)
function manual_request_updates_persisted_status(logger) {
 var o=requestSetup();var req=new MockRequest(o.method(:done));req.start(true);
 Test.assertEqual(req.sends,1);
 var r=Cache.load(Config.location());Test.assert(r["failed"]);
 req.response(200,{"alerts"=>[{"location_uid"=>"31","location_type"=>"city","alert_type"=>"air_raid","alert_level"=>"yellow"}]});
 r=Cache.load(Config.location());Test.assertEqual(r["state"],AlertLogic.YELLOW);Test.assert(!r["failed"]);Test.assertEqual(o.finished,1);return true;
}
(:test)
function old_response_cannot_contaminate_new_city(logger) {
 var o=requestSetup();var req=new MockRequest(o.method(:done));req.start(true);
 Application.Properties.setValue("cityUid",845);Cache.load(Config.location());
 req.response(200,{"alerts"=>[]});var r=Cache.load(Config.location());
 Test.assertEqual(r["uid"],845);Test.assertEqual(r["success"],0);return true;
}
(:test)
function shared_gate_survives_city_switch(logger) {
 var o=requestSetup();var first=new MockRequest(o.method(:done));first.start(true);
 Application.Properties.setValue("cityUid",845);var second=new MockRequest(o.method(:done));second.start(true);
 Test.assertEqual(first.sends,1);Test.assertEqual(second.sends,0);return true;
}
(:test)
function malformed_json_callback_is_unknown(logger) {
 var o=requestSetup();var req=new MockRequest(o.method(:done));req.start(true);req.response(-400,null);
 var r=Cache.load(Config.location());Test.assert(r["failed"]);Test.assertEqual(r["success"],0);return true;
}
