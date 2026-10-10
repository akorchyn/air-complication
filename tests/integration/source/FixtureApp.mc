using Toybox.Application;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi;
using Toybox.Graphics;
import Toybox.Lang;
(:background)
class FixtureApp extends AirAlertApp {
    function initialize() { AirAlertApp.initialize(); }
    function getServiceDelegate() { return [new FixtureService()]; }
    function newRequest(done as Lang.Method) { return new FixtureRequest(done); }
    function getInitialView() {
        Application.Properties.setValue("cityUid",31);
        Application.Properties.setValue("apiProvider",0);
        Application.Properties.setValue("displayMode",ProbeConfig.DISPLAY_MODE);
        Application.Properties.setValue("apiToken","SIMULATOR_FIXTURE_ONLY");
        Application.Properties.setValue("refreshMinutes",5);
        Application.Storage.deleteValue("cache");Application.Storage.deleteValue("requestGate");Application.Storage.setValue("fixtureStep",0);
        var loc=Config.location();var r=Cache.load(loc);
        Cache.publish(r,loc,Time.now().value());Cache.schedule(r,Time.now().value());
        System.println("FIXTURE READY");
        return [new FixtureView(),new AlertDelegate()];
    }
}
(:background)
class FixtureService extends AlertService {
    function initialize() { AlertService.initialize(); }
    function onTemporalEvent() as Void {
        // Simulator-triggered events run immediately; make this fixture due.
        var r=Cache.load(Config.location());r["next"]=0;r["request"]=0;r["lease"]=0;Cache.save(r);Application.Storage.deleteValue("requestGate");
        System.println("INTEGRATION: background event");
        AlertService.onTemporalEvent();
    }
}
(:background)
class FixtureRequest extends AlertRequest {
    function initialize(done as Lang.Method) { AlertRequest.initialize(done); }
    function send(token) {
        var step=Application.Storage.getValue("fixtureStep");
        if (!(step instanceof Number)) { step=0; }
        Application.Storage.setValue("fixtureStep",step+1);
        if (step>=2) {
            System.println("INTEGRATION: response clear");
            response(200,{"alerts"=>[]});return;
        }
        var level=step==0 ? "yellow" : "red";
        System.println("INTEGRATION: response "+level);
        var before=System.getSystemStats();System.println("INTEGRATION: response memory used="+before.usedMemory+" free="+before.freeMemory);
        var rows=ProbeConfig.ROWS;
        var alerts=[];
        if (rows<=0) { rows=1; }
        var base=System.getSystemStats();System.println("MEMORY: before rows="+rows+" used="+base.usedMemory+" free="+base.freeMemory);
        for(var i=0;i<rows;i++) {
            // Allocate distinct dictionaries and strings, including realistic long
            // threat source text, rather than recycling one object reference.
            var message="Synthetic threat text for memory measurement "+i+" ";
            for(var j=0;j<4;j++) { message=message+message; }
            alerts.add({"id"=>i,"location_uid"=>"31","location_type"=>"city","alert_type"=>"air_raid","alert_level"=>level,
                "location_title"=>"Kyiv city "+i,"location_oblast_uid"=>"31",
                "started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:01:00Z",
                "threats"=>[{"threat_type"=>"drones","level"=>level,"source_message"=>message}]});
        }
        var peak=System.getSystemStats();System.println("MEMORY: after rows="+rows+" used="+peak.usedMemory+" free="+peak.freeMemory);
        response(200,{"alerts"=>alerts});
        var stats=System.getSystemStats();
        System.println("INTEGRATION: memory used="+stats.usedMemory+" free="+stats.freeMemory);
    }
}
class FixtureView extends WatchUi.View {
    function initialize() { View.initialize(); }
    function onUpdate(dc) {
        var font=WatchUi.loadResource(Rez.Fonts.TestFont);
        var r=Cache.load(Config.location());
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);dc.clear();
        dc.drawText(208,150,font,"FIXTURE KYIV",Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(208,195,font,AlertLogic.text(AlertLogic.visible(r,Time.now().value(),600)),Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(208,250,font,"START: Refresh",Graphics.TEXT_JUSTIFY_CENTER);
    }
}
