using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Background;
using Toybox.Time;
import Toybox.Lang;
(:background)
class PowerApp extends Application.AppBase {
    function initialize() { AppBase.initialize(); }
    function newRequest(done as Lang.Method) { return new PowerRequest(done); }
    function getServiceDelegate() { return [new PowerService()]; }
    function getInitialView() {
        var r=PowerCache.load();var now=Time.now().value();PowerCache.publish(r,now);PowerCache.schedule(r,now);
        var view=new PowerView();return [view,new PowerDelegate(view)];
    }
    function getGlanceView() { return [new PowerGlance()]; }
    function onSettingsChanged() as Void {
        var r=PowerCache.load();r["failed"]=true;r["failures"]=0;r["next"]=0;r["lease"]=0;r["sequence"]=0;
        PowerCache.save(r);PowerCache.publish(r,Time.now().value());PowerCache.schedule(r,Time.now().value());WatchUi.requestUpdate();
    }
    function onBackgroundData(data) { WatchUi.requestUpdate(); }
    function onStorageChanged() { WatchUi.requestUpdate(); }
}
(:background)
class PowerService extends System.ServiceDelegate {
    var _request;
    function initialize() { ServiceDelegate.initialize(); }
    function onTemporalEvent() as Void {
        var r=PowerCache.load();var now=Time.now().value();PowerCache.publish(r,now);PowerCache.schedule(r,now);
        _request=Application.getApp().newRequest(method(:done));_request.start(false);
    }
    function done() as Void { PowerCache.schedule(PowerCache.load(),Time.now().value());Background.exit(null); }
}
