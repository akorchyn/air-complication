using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Time;
import Toybox.Lang;
using Toybox.System;
(:background)
class AirAlertApp extends Application.AppBase {
    var _settings as Array or Null;
    function initialize() { AppBase.initialize(); }
    function newRequest(done as Lang.Method) { return new AlertRequest(done); }
    function getServiceDelegate() { return [new AlertService()]; }
    function getInitialView() {
        _settings=settingsSnapshot();
        LocationCatalog.resolveCustom();
        var loc=Config.location();var r=Cache.load(loc);var now=Time.now().value();
        Cache.publish(r,loc,now);Cache.schedule(r,now);
        return [new AlertView(),new AlertDelegate()];
    }
    function onSettingsChanged() as Void {
        var snapshot=settingsSnapshot();
        // Presentation-only edits must not discard a valid check, interrupt an
        // in-flight request, reset backoff, or move the next background event.
        var presentationOnly=sameSettings(snapshot);_settings=snapshot;
        LocationCatalog.resolveCustom();
        var loc=Config.location();var r=Cache.load(loc);
        if (!presentationOnly) {
            // A changed token allows recovery from a 401 backoff immediately.
            r["failures"]=0;r["next"]=0;r["modified"]=null;
            // Also reject callbacks from requests started before these settings.
            r["sequence"]=0;r["request"]=0;r["lease"]=0;r["failed"]=true;
            Cache.save(r);Cache.schedule(r,Time.now().value());
        }
        Cache.publish(r,loc,Time.now().value());
        SettingsMenu.refresh();
        WatchUi.requestUpdate();
    }
    function settingsSnapshot() as Array {
        // In-memory only. Credentials remain in application properties; never
        // persist or print this snapshot. displayMode is intentionally omitted.
        var keys=["apiProvider","apiToken","ukraineAlarmToken","cityUid","customUid","customLabel","refreshMinutes","staleMinutes"];
        var values=[];
        for (var i=0;i<keys.size();i++) { values.add(Application.Properties.getValue(keys[i])); }
        return values;
    }
    function sameSettings(snapshot as Array) {
        if (!(_settings instanceof Array) || _settings.size()!=snapshot.size()) { return false; }
        for (var i=0;i<snapshot.size();i++) {
            var old=_settings[i];var value=snapshot[i];
            if (old instanceof String) {
                if (!(value instanceof String) || !old.equals(value)) { return false; }
            } else if (old!=value) { return false; }
        }
        return true;
    }
    function onBackgroundData(data) { WatchUi.requestUpdate(); }
    function onStorageChanged() { WatchUi.requestUpdate(); }
}
