using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Time;
import Toybox.Lang;
using Toybox.System;
(:background)
class AirAlertApp extends Application.AppBase {
    function initialize() { AppBase.initialize(); }
    function newRequest(done as Lang.Method) { return new AlertRequest(done); }
    function getServiceDelegate() { return [new AlertService()]; }
    function getInitialView() {
        LocationCatalog.resolveCustom();
        var loc=Config.location();var r=Cache.load(loc);var now=Time.now().value();
        Cache.publish(r,loc,now);Cache.schedule(r,now);
        return [new AlertView(),new AlertDelegate()];
    }
    function onSettingsChanged() as Void {
        LocationCatalog.resolveCustom();
        var loc=Config.location();var r=Cache.load(loc);
        // A changed token allows recovery from a 401 backoff immediately.
        r["failures"]=0;r["next"]=0;r["modified"]=null;
        // Also reject callbacks from requests started before these settings.
        r["sequence"]=0;r["request"]=0;r["lease"]=0;r["failed"]=true;
        Cache.save(r);Cache.publish(r,loc,Time.now().value());Cache.schedule(r,Time.now().value());
        WatchUi.requestUpdate();
    }
    function onBackgroundData(data) { WatchUi.requestUpdate(); }
    function onStorageChanged() { WatchUi.requestUpdate(); }
}
