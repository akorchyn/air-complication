using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.System;
import Toybox.Lang;
(:background)
class PowerFixtureApp extends PowerApp {
    function initialize() { PowerApp.initialize(); }
    function newRequest(done as Lang.Method) { return new FixtureRequest(done); }
    function getInitialView() {
        Application.Properties.setValue("adapterUrl","https://fixture.example");
        Application.Properties.setValue("group","19.1");Application.Properties.setValue("profile",0);
        Application.Storage.deleteValue("powerCache");Application.Storage.deleteValue("powerGate");Application.Storage.setValue("fixtureStep",0);
        var view=new FixtureView();return [view,new PowerDelegate(view)];
    }
    function getServiceDelegate() { return [new FixtureService()]; }
}
(:background)
class FixtureRequest extends PowerRequest {
    function initialize(done as Lang.Method) { PowerRequest.initialize(done); }
    function send() {
        var step=Application.Storage.getValue("fixtureStep");if(!(step instanceof Number)) { step=0; }
        var data=PowerFixtures.current(Time.now().value(),step>0);
        if(step>0) {
            // Exercise the maximum 128-slot projected shape in background. Its
            // slot covering the query minute is ON, unlike the first response.
            for(var i=0;i<data["days"].size();i++) {
                for(var j=0;j<data["days"][i][4].size();j++) { data["days"][i][4][j][2]=0; }
            }
        }
        Application.Storage.setValue("fixtureStep",step+1);
        var stats=System.getSystemStats();System.println("POWER MEMORY used="+stats.usedMemory+" free="+stats.freeMemory);
        var callback=new PowerResponse(self,_sequence);callback.onReceive(200,data);
    }
}
(:background)
class FixtureService extends PowerService {
    function initialize() { PowerService.initialize(); }
    function onTemporalEvent() as Void {
        var r=PowerCache.load();r["next"]=0;r["request"]=0;r["lease"]=0;PowerCache.save(r);Application.Storage.deleteValue("powerGate");
        System.println("POWER BACKGROUND");PowerService.onTemporalEvent();
    }
    function done() as Void {
        var r=PowerCache.load();PowerCache.schedule(r,Time.now().value());
        var stats=System.getSystemStats();System.println("POWER FINISH MEMORY used="+stats.usedMemory+" free="+stats.freeMemory);
        Toybox.Background.exit(null);
    }
}
class FixtureView extends PowerView {
    function initialize() { PowerView.initialize(); }
    function onUpdate(dc) {
        var s=PowerLogic.summary(PowerCache.load(),Time.now().value());
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);dc.clear();
        dc.drawText(dc.getWidth()/2,dc.getHeight()/2-20,WatchUi.loadResource(Rez.Fonts.TestFont),s["value"],Graphics.TEXT_JUSTIFY_CENTER);
    }
}
