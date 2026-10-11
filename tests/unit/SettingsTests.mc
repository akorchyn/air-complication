using Toybox.Application;
using Toybox.Time;
using Toybox.Test;

// Phone-delivered settings use the production AppBase callback. No watch menu
// is involved; exercise cache invalidation and the surviving request callback.
(:test)
function mobile_provider_change_preserves_key_and_rejects_previous_response(logger) {
    var o=requestSetup();
    Application.Properties.setValue("ukraineAlarmToken","UKRAINE_FIXTURE_ONLY");
    var app=Application.getApp();app._settings=app.settingsSnapshot();
    var req=new MockRequest(o.method(:done));req.start(true);
    Application.Properties.setValue("apiProvider",1);app.onSettingsChanged();
    Test.assertEqual(Config.token(),"UKRAINE_FIXTURE_ONLY");
    var r=Cache.load(Config.location());Test.assert(r["failed"]);
    Test.assertEqual(r["success"],0);Test.assertEqual(r["sequence"],0);
    req.callbacks[0].invoke(200,uaRegion(31,null));
    Test.assertEqual(Cache.load(Config.location())["success"],0);
    Application.Properties.setValue("apiProvider",2);app.onSettingsChanged();
    Test.assert(!Config.needsToken());Test.assertEqual(Config.providerName(),"UA Siren");
    Test.assertEqual(Application.Properties.getValue("ukraineAlarmToken"),"UKRAINE_FIXTURE_ONLY");
    Test.assertEqual(Config.token(),"");
    return true;
}

(:test)
function mobile_location_and_intervals_resolve_without_watch_menu(logger) {
    var r=resetTest();Cache.success(r,AlertLogic.NONE,Time.now().value());Cache.save(r);
    var app=Application.getApp();app._settings=app.settingsSnapshot();
    Application.Properties.setValue("cityUid",0);
    Application.Properties.setValue("customUid","332");
    Application.Properties.setValue("customLabel","DNIP");
    Application.Properties.setValue("refreshMinutes",30);
    Application.Properties.setValue("staleMinutes",15);
    app.onSettingsChanged();
    var loc=Config.location();r=Cache.load(loc);
    Test.assertEqual(loc["uid"],332);Test.assertEqual(loc["oblast"],9);
    Test.assertEqual(Config.interval(),1800);Test.assertEqual(Config.staleSeconds(),900);
    Test.assertEqual(r["success"],0);Test.assert(r["failed"]);
    Test.assertEqual(AlertLogic.visible(r,Time.now().value(),900),AlertLogic.UNKNOWN);
    return true;
}

(:test)
function mobile_token_edit_recovers_from_auth_backoff_without_revalidating_history(logger) {
    resetTest();Application.Properties.setValue("apiProvider",1);
    var r=Cache.load(Config.location());var now=Time.now().value();
    Cache.success(r,AlertLogic.NONE,now-120);Cache.failure(r,401,now);Cache.save(r);
    var previous=r["success"];var app=Application.getApp();app._settings=app.settingsSnapshot();
    Application.Properties.setValue("ukraineAlarmToken","NEW_FIXTURE_ONLY");app.onSettingsChanged();
    r=Cache.load(Config.location());
    Test.assertEqual(Config.token(),"NEW_FIXTURE_ONLY");Test.assertEqual(r["failures"],0);
    Test.assertEqual(r["next"],0);Test.assertEqual(r["success"],previous);Test.assert(r["failed"]);
    Test.assertEqual(AlertLogic.visible(r,now,600),AlertLogic.UNKNOWN);
    return true;
}
