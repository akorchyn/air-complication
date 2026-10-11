using Toybox.Application;
using Toybox.Time;
using Toybox.Test;
import Toybox.Lang;
// A controllable transport exercises the real request lifecycle and persistence.
class MockRequest extends AlertRequest {
 var sends=0;
 var callbacks=[];
 function initialize(done as Lang.Method) { AlertRequest.initialize(done); }
 function send(token) { sends+=1;callbacks.add(responseHandler().method(:onReceive)); }
}
class RequestObserver {
 var finished=0;
 function initialize() {}
 function done() as Void { finished+=1; }
}
function requestSetup() as RequestObserver {
 resetTest();Application.Properties.setValue("apiToken","FIXTURE_ONLY");
 Application.Storage.deleteValue("requestGate");return new RequestObserver();
}
(:test)
function two_argument_callback_accepts_public_provider_root_array(logger) {
 var o=requestSetup();Application.Properties.setValue("apiProvider",2);
 var req=new MockRequest(o.method(:done));req.start(true);
 req.callbacks[0].invoke(200,uaRegion(31,[{"alertLevel"=>"Yellow"}]));
 Test.assertEqual(o.finished,1);Test.assertEqual(Cache.load(Config.location())["state"],AlertLogic.YELLOW);return true;
}
(:test)
function two_argument_immediate_network_error_finishes_without_crash(logger) {
 var o=requestSetup();var req=new MockRequest(o.method(:done));req.start(true);
 req.callbacks[0].invoke(-104,null);
 var r=Cache.load(Config.location());Test.assert(r["failed"]);Test.assertEqual(r["lease"],0);
 Test.assertEqual(r["error"],"Phone/network unavailable");Test.assertEqual(o.finished,1);return true;
}
(:test)
function two_argument_rate_limit_callback_preserves_history_and_backoff(logger) {
 var o=requestSetup();var now=Time.now().value();var r=Cache.load(Config.location());
 Cache.success(r,AlertLogic.RED,now-120);Cache.save(r);
 var req=new MockRequest(o.method(:done));req.start(true);req.callbacks[0].invoke(429,null);
 r=Cache.load(Config.location());Test.assertEqual(r["state"],AlertLogic.RED);Test.assertEqual(r["success"],now-120);
 Test.assertEqual(r["error"],"429: Rate limited");Test.assert(r["next"]>=now+900);Test.assertEqual(o.finished,1);return true;
}
(:test)
function duplicate_parent_callback_cannot_be_used_for_next_query(logger) {
 var o=requestSetup();Application.Properties.setValue("apiProvider",2);Application.Properties.setValue("cityUid",845);
 var req=new MockRequest(o.method(:done));req.start(true);
 req.callbacks[0].invoke(200,uaRegion(845,null));Test.assertEqual(req.sends,2);
 req.callbacks[0].invoke(200,uaRegion(845,null));Test.assertEqual(req.sends,2);Test.assertEqual(o.finished,0);
 req.callbacks[1].invoke(200,uaRegion(27,null));req.callbacks[2].invoke(200,uaRegion(90,null));
 Test.assertEqual(o.finished,1);Test.assertEqual(Cache.load(Config.location())["state"],AlertLogic.NONE);
 req.callbacks[2].invoke(200,uaRegion(90,null));Test.assertEqual(o.finished,1);return true;
}
(:test)
function old_bound_callback_cannot_update_a_later_cycle(logger) {
 var o=requestSetup();var req=new MockRequest(o.method(:done));req.start(true);
 req.callbacks[0].invoke(200,{"alerts"=>[]});
 var r=Cache.load(Config.location());r["request"]=0;r["next"]=0;Cache.save(r);Application.Storage.deleteValue("requestGate");
 req.start(true);req.callbacks[0].invoke(200,{"alerts"=>[]});Test.assertEqual(o.finished,1);
 req.callbacks[1].invoke(200,{"alerts"=>[{"location_uid"=>"31","location_type"=>"city","alert_type"=>"air_raid","alert_level"=>"red"}]});
 Test.assertEqual(o.finished,2);Test.assertEqual(Cache.load(Config.location())["state"],AlertLogic.RED);return true;
}
(:test)
function two_argument_callback_discards_result_after_location_change(logger) {
 var o=requestSetup();var req=new MockRequest(o.method(:done));req.start(true);
 Application.Properties.setValue("cityUid",845);req.callbacks[0].invoke(200,{"alerts"=>[]});
 Test.assertEqual(Cache.load(Config.location())["uid"],845);Test.assertEqual(Cache.load(Config.location())["success"],0);return true;
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

function uaRegion(uid, levels) {
 var alerts=[];
 if (levels!=null) { alerts.add({"regionId"=>""+uid,"regionType"=>"State","type"=>"AIR","activeAlertLevels"=>levels}); }
 return [{"regionId"=>""+uid,"regionType"=>"State","activeAlerts"=>alerts}];
}
(:test)
function public_provider_needs_no_token(logger) {
 var o=requestSetup();Application.Properties.setValue("apiToken","");Application.Properties.setValue("apiProvider",2);
 var req=new MockRequest(o.method(:done));req.start(true);Test.assertEqual(req.sends,1);
 req.response(200,uaRegion(31,null));Test.assertEqual(Cache.load(Config.location())["state"],AlertLogic.NONE);return true;
}
(:test)
function official_provider_uses_separate_key(logger) {
 var o=requestSetup();Application.Properties.setValue("apiProvider",1);Application.Properties.setValue("ukraineAlarmToken","");
 var req=new MockRequest(o.method(:done));req.start(true);Test.assertEqual(req.sends,0);
 Application.Properties.setValue("ukraineAlarmToken","FIXTURE_UKRAINE_ONLY");
 Test.assertEqual(Config.token(),"FIXTURE_UKRAINE_ONLY");return true;
}
(:test)
function provider_switch_invalidates_cache(logger) {
 var r=resetTest();Cache.accept(r,200,{"alerts"=>[]},Config.location(),1000);Cache.save(r);
 Application.Properties.setValue("apiProvider",2);r=Cache.load(Config.location());Test.assertEqual(r["success"],0);return true;
}
(:test)
function old_provider_response_is_discarded(logger) {
 var o=requestSetup();var req=new MockRequest(o.method(:done));req.start(true);
 Application.Properties.setValue("apiProvider",2);req.response(200,{"alerts"=>[]});
 Test.assertEqual(Cache.load(Config.location())["success"],0);return true;
}
(:test)
function city_requires_all_parent_checks_before_clear(logger) {
 var o=requestSetup();Application.Properties.setValue("apiProvider",2);Application.Properties.setValue("cityUid",845);
 var req=new MockRequest(o.method(:done));req.start(true);req.response(200,uaRegion(845,null));
 Test.assertEqual(req.sends,2);Test.assertEqual(o.finished,0);Test.assert(Cache.load(Config.location())["failed"]);
 req.response(200,uaRegion(27,null));Test.assertEqual(req.sends,3);Test.assertEqual(o.finished,0);
 req.response(200,uaRegion(90,null));Test.assertEqual(o.finished,1);Test.assertEqual(Cache.load(Config.location())["state"],AlertLogic.NONE);return true;
}
(:test)
function parent_failure_never_clears_city(logger) {
 var o=requestSetup();Application.Properties.setValue("apiProvider",2);Application.Properties.setValue("cityUid",845);
 var req=new MockRequest(o.method(:done));req.start(true);req.response(200,uaRegion(845,null));req.response(429,null);
 Test.assert(Cache.load(Config.location())["failed"]);Test.assertEqual(req.sends,2);return true;
}
(:test)
function parent_red_stops_remaining_requests(logger) {
 var o=requestSetup();Application.Properties.setValue("apiProvider",2);Application.Properties.setValue("cityUid",845);
 var req=new MockRequest(o.method(:done));req.start(true);req.response(200,uaRegion(845,null));
 req.response(200,uaRegion(27,[{"alertLevel"=>"Red"}]));
 Test.assertEqual(req.sends,2);Test.assertEqual(o.finished,1);Test.assertEqual(Cache.load(Config.location())["state"],AlertLogic.RED);return true;
}
(:test)
function unsupported_provider_location_avoids_network(logger) {
 var o=requestSetup();Application.Properties.setValue("apiProvider",2);Application.Properties.setValue("cityUid",30);
 var req=new MockRequest(o.method(:done));req.start(true);Test.assertEqual(req.sends,0);Test.assert(Cache.load(Config.location())["failed"]);return true;
}
(:test)
function provider_auth_headers_and_request_scope(logger) {
 Test.assertEqual(ApiProvider.headers(0,"TOKEN")["Authorization"],"Bearer TOKEN");
 Test.assertEqual(ApiProvider.headers(1,"KEY")["Authorization"],"KEY");Test.assert(!ApiProvider.headers(2,"").hasKey("Authorization"));
 resetTest();Application.Properties.setValue("cityUid",845);Test.assertEqual(ApiProvider.queries(2,Config.location()).size(),3);
 Application.Properties.setValue("cityUid",27);LocationCatalog.resolveCustom();Test.assertEqual(ApiProvider.queries(2,Config.location())[0],0);return true;
}
(:test)
function volyn_hierarchy_is_not_crimea(logger) {
 Test.assertEqual(LocationCatalog.parents(255)[0],8);Test.assert(LocationCatalog.members(8).find("|255|")!=null);return true;
}
