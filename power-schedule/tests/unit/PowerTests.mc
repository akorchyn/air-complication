using Toybox.Application;
using Toybox.Test;
using Toybox.Time;
import Toybox.Lang;
function powerReset() as Dictionary {
    Application.Properties.setValue("adapterUrl","https://adapter.example");Application.Properties.setValue("adapterToken","");
    Application.Properties.setValue("profile",0);Application.Properties.setValue("group","19.1");
    Application.Properties.setValue("refreshMinutes",15);Application.Properties.setValue("staleMinutes",30);
    Application.Storage.deleteValue("powerCache");Application.Storage.deleteValue("powerGate");
    var r=PowerCache.fresh();r["data"]=PowerFixtures.payload();r["failed"]=false;r["fetched"]=PowerFixtures.NOW;
    return r;
}
function currentPowerPayload(now) as Dictionary {
    var data=PowerFixtures.payload();var delta=now-data["checkedAt"];data["checkedAt"]=now;data["updatedAt"]=now-900;
    for(var i=0;i<data["days"].size();i++) {
        var day=data["days"][i];day[1]+=delta;day[2]+=delta;
        for(var j=0;j<day[4].size();j++) { day[4][j][0]+=delta;day[4][j][1]+=delta; }
    }return data;
}
class PowerObserver { var count=0;function initialize() {}function done() as Void { count+=1; } }
class MockPowerRequest extends PowerRequest {
    var sends=0;
    function initialize(done as Lang.Method) { PowerRequest.initialize(done); }
    function send() { sends+=1; }
    function answer(code,data) { var cb=new PowerResponse(self,_sequence);cb.onReceive(code,data); }
}
(:test)
function scheduled_off_and_restoration(logger) {
    var r=powerReset();var s=PowerLogic.summary(r,PowerFixtures.NOW);
    Test.assertEqual(s["value"],"OFF 10:00");Test.assertEqual(s["out"],"NOW");Test.assertEqual(s["back"],"10:00");return true;
}
(:test)
function scheduled_on_next_outage(logger) {
    var r=powerReset();r["data"]["checkedAt"]-=7200;r["data"]["updatedAt"]-=7200;r["fetched"]-=7200;
    var s=PowerLogic.summary(r,PowerFixtures.NOW-7200);
    Test.assertEqual(s["value"],"ON 08:00");Test.assertEqual(s["out"],"08:00");return true;
}
(:test)
function half_open_boundaries_and_no_known_future(logger) {
    var r=powerReset();r["data"]["checkedAt"]+=3600;r["fetched"]+=3600;
    var s=PowerLogic.summary(r,PowerFixtures.NOW+3600);
    Test.assertEqual(s["state"],"ON");Test.assertEqual(s["out"],"--");Test.assertEqual(s["back"],"--");return true;
}
(:test)
function waiting_and_emergency_are_not_on(logger) {
    var r=powerReset();var day=r["data"]["days"][0];day[4]=[];
    day[3]=2;Test.assertEqual(PowerLogic.summary(r,PowerFixtures.NOW)["value"],"WAIT");
    day[3]=3;Test.assertEqual(PowerLogic.summary(r,PowerFixtures.NOW)["value"],"EMERG");
    day[3]=4;Test.assertEqual(PowerLogic.summary(r,PowerFixtures.NOW)["value"],"N/A");return true;
}
(:test)
function incomplete_day_gap_is_unknown(logger) {
    var r=powerReset();var slots=r["data"]["days"][0][4];slots.remove(slots[1]);
    Test.assertEqual(PowerLogic.summary(r,PowerFixtures.NOW)["value"],"N/A");return true;
}
(:test)
function explicit_no_outages_requires_whole_day_on(logger) {
    var r=powerReset();var day=r["data"]["days"][0];day[3]=0;
    Test.assert(!PowerLogic.valid(r["data"],PowerFixtures.NOW));
    day[4]=[[day[1],day[2],0,0,1440]];
    Test.assertEqual(PowerLogic.summary(r,PowerFixtures.NOW)["value"],"ON");return true;
}
(:test)
function stale_boundary_does_not_extend_on_fetch(logger) {
    var r=powerReset();Test.assertEqual(PowerLogic.summary(r,PowerFixtures.NOW+1799)["state"],"OFF");
    Test.assertEqual(PowerLogic.summary(r,PowerFixtures.NOW+1800)["state"],"STALE");
    r["fetched"]+=1800;Test.assertEqual(PowerLogic.summary(r,PowerFixtures.NOW+1800)["state"],"STALE");return true;
}
(:test)
function failed_pending_interrupted_and_clock_rollback(logger) {
    var r=powerReset();r["failed"]=true;Test.assertEqual(PowerLogic.summary(r,PowerFixtures.NOW)["state"],"N/A");
    r["failed"]=false;r["lease"]=PowerFixtures.NOW+60;Test.assertEqual(PowerLogic.summary(r,PowerFixtures.NOW)["state"],"OFF");
    Test.assertEqual(PowerLogic.summary(r,PowerFixtures.NOW+60)["state"],"N/A");
    Test.assertEqual(PowerLogic.summary(r,PowerFixtures.NOW-1)["state"],"N/A");return true;
}
(:test)
function malformed_or_wrong_scope_payloads_are_rejected(logger) {
    powerReset();var keys=["schema","region","dso","group","checkedAt","updatedAt","days"];
    for(var i=0;i<keys.size();i++) { var d=PowerFixtures.payload();d[keys[i]]=null;Test.assert(!PowerLogic.valid(d,PowerFixtures.NOW)); }
    var d=PowerFixtures.payload();d["group"]="20.1";Test.assert(!PowerLogic.valid(d,PowerFixtures.NOW));
    d=PowerFixtures.payload();d["days"][0][4][1][2]=9;Test.assert(!PowerLogic.valid(d,PowerFixtures.NOW));
    d=PowerFixtures.payload();d["days"][0][4][1][0]-=7200;Test.assert(!PowerLogic.valid(d,PowerFixtures.NOW));return true;
}
(:test)
function unconfigured_adapter_is_setup_not_on(logger) {
    var r=powerReset();Application.Properties.setValue("adapterUrl","");
    Test.assertEqual(PowerLogic.summary(r,PowerFixtures.NOW)["state"],"SETUP");
    var o=new PowerObserver();var req=new MockPowerRequest(o.method(:done));req.start(true);
    Test.assertEqual(req.sends,0);Test.assertEqual(o.count,1);return true;
}
(:test)
function group_profiles_https_validation_and_defaults(logger) {
    powerReset();Test.assert(PowerConfig.ready());Test.assertEqual(PowerConfig.region(),25);Test.assertEqual(PowerConfig.dso(),902);
    Application.Properties.setValue("profile",1);Test.assertEqual(PowerConfig.region(),3);Test.assertEqual(PowerConfig.dso(),301);
    Application.Properties.setValue("profile",2);Test.assertEqual(PowerConfig.dso(),303);
    Application.Properties.setValue("adapterUrl","http://adapter.example");Test.assert(!PowerConfig.ready());
    Application.Properties.setValue("adapterUrl","https://adapter.example/");Test.assert(PowerConfig.ready());
    var groups=["","0.1","19","19.0","1/1","19.1&foo=1"];
    for(var i=0;i<groups.size();i++) { Application.Properties.setValue("group",groups[i]);Test.assert(!PowerConfig.ready()); }return true;
}
(:test)
function group_change_discards_previous_status(logger) {
    var r=powerReset();PowerCache.save(r);Application.Properties.setValue("group","20.1");
    r=PowerCache.load();Test.assertEqual(r["fetched"],0);Test.assert(r["failed"]);return true;
}
(:test)
function network_success_two_argument_callback_and_duplicate(logger) {
    powerReset();var o=new PowerObserver();var req=new MockPowerRequest(o.method(:done));req.start(true);
    Test.assertEqual(req.sends,1);req.answer(200,currentPowerPayload(Time.now().value()));
    Test.assertEqual(o.count,1);Test.assert(!PowerCache.load()["failed"]);
    Test.assertEqual(PowerLogic.summary(PowerCache.load(),Time.now().value())["state"],"OFF");
    req.answer(500,null);Test.assertEqual(o.count,1);return true;
}
(:test)
function http_and_transport_errors_keep_history_without_showing_on(logger) {
    var codes=[304,401,403,429,500,503,-104,-400,-402,-403];
    for(var i=0;i<codes.size();i++) {
        var r=powerReset();var now=Time.now().value();r["data"]=currentPowerPayload(now);r["fetched"]=now;PowerCache.save(r);
        var o=new PowerObserver();var req=new MockPowerRequest(o.method(:done));req.start(true);req.answer(codes[i],null);
        r=PowerCache.load();Test.assert(r["failed"]);Test.assertEqual(r["fetched"],now);
        Test.assertEqual(PowerLogic.summary(r,now)["state"],"N/A");Test.assert(r["next"]>=now+300);
    }return true;
}
(:test)
function failure_backoff_and_recovery(logger) {
    powerReset();var o=new PowerObserver();var req=new MockPowerRequest(o.method(:done));req.start(true);req.answer(-104,null);
    req.start(true);Test.assertEqual(req.sends,1);
    var r=PowerCache.load();r["next"]=0;r["request"]=0;PowerCache.save(r);Application.Storage.deleteValue("powerGate");
    req.start(true);Test.assertEqual(req.sends,2);req.answer(200,currentPowerPayload(Time.now().value()));Test.assert(!PowerCache.load()["failed"]);return true;
}
(:test)
function manual_gate_and_background_fresh_cache_avoid_polling(logger) {
    powerReset();var o=new PowerObserver();var req=new MockPowerRequest(o.method(:done));req.start(true);
    var second=new MockPowerRequest(o.method(:done));second.start(true);Test.assertEqual(second.sends,0);
    req.answer(200,currentPowerPayload(Time.now().value()));
    var r=PowerCache.load();r["request"]=0;PowerCache.save(r);Application.Storage.deleteValue("powerGate");
    second.start(false);Test.assertEqual(second.sends,0);return true;
}
(:test)
function old_callback_after_settings_change_is_discarded(logger) {
    powerReset();var o=new PowerObserver();var req=new MockPowerRequest(o.method(:done));req.start(true);
    Application.Properties.setValue("group","20.1");Application.getApp().onSettingsChanged();
    req.answer(200,currentPowerPayload(Time.now().value()));Test.assertEqual(PowerCache.load()["fetched"],0);return true;
}
(:test)
function unknown_data_in_200_is_not_success(logger) {
    powerReset();var o=new PowerObserver();var req=new MockPowerRequest(o.method(:done));req.start(true);req.answer(200,{});
    Test.assert(PowerCache.load()["failed"]);Test.assertEqual(PowerCache.load()["fetched"],0);return true;
}
(:test)
function glance_factory_does_not_start_request(logger) {
    powerReset();Application.Storage.deleteValue("powerCache");
    var views=Application.getApp().getGlanceView();Test.assertEqual(views.size(),1);
    Test.assert(Application.Storage.getValue("powerGate")==null);Test.assert(Application.Storage.getValue("powerCache")==null);return true;
}

(:test)
function adjacent_outages_merge_across_midnight(logger) {
    var r=powerReset();var days=r["data"]["days"];var at=days[0][2]-1800;
    days[0][4]=[[days[0][1],days[0][2]-3600,0,0,1380],[days[0][2]-3600,days[0][2],1,1380,1440]];
    days[1][3]=1;days[1][4]=[[days[1][1],days[1][1]+3600,1,0,60],[days[1][1]+3600,days[1][2],0,60,1440]];
    r["data"]["checkedAt"]=at;r["fetched"]=at;
    Test.assertEqual(PowerLogic.summary(r,at)["value"],"OFF T 01:00");return true;
}

(:test)
function no_restoration_claim_at_unknown_horizon(logger) {
    var r=powerReset();var day=r["data"]["days"][0];day[4]=[day[4][0],day[4][1]];
    var s=PowerLogic.summary(r,PowerFixtures.NOW);Test.assertEqual(s["value"],"OFF");Test.assertEqual(s["back"],"--");return true;
}

(:test)
function opening_fetches_once_per_view_and_uses_manual_request_gate(logger) {
    powerReset();var view=new PowerView();var req=new MockPowerRequest(view.method(:done));view._request=req;
    view.onShow();Test.assertEqual(req.sends,1);req.answer(200,currentPowerPayload(Time.now().value()));
    view.onHide();view.onShow();Test.assertEqual(req.sends,1);view.onHide();return true;
}

class GlanceCanvas {
    var rows=[];
    function initialize() {}
    function setColor(a,b) {}
    function clear() { rows=[]; }
    function getHeight() { return 100; }
    function getWidth() { return 240; }
    function drawText(x,y,font,text,justification) { rows.add(text); }
}
(:test)
function glance_renders_cache_and_changes_to_unavailable_without_network(logger) {
    var now=Time.now().value();var r=powerReset();r["fetched"]=now;r["data"]=currentPowerPayload(now);PowerCache.save(r);
    var glance=new PowerGlance();var dc=new GlanceCanvas();glance.onUpdate(dc);
    Test.assertEqual(dc.rows[1],"OFF 10:00");Test.assert(Application.Storage.getValue("powerGate")==null);
    r["failed"]=true;PowerCache.save(r);glance.onUpdate(dc);Test.assertEqual(dc.rows[1],"N/A");return true;
}
