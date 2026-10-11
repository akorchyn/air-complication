using Toybox.Application;
using Toybox.Time;
using Toybox.Test;
import Toybox.Lang;

(:test)
function default_public_provider_opens_and_fetches_without_credentials(logger) {
    requestSetup();
    Test.assertEqual(Config.providerName(),"UA Siren");Test.assert(!Config.needsToken());
    var f=openFixture();f[0].onShow();Test.assertEqual(f[2].sends,1);
    f[2].callbacks[0].invoke(200,uaRegion(31,null));
    var r=Cache.load(Config.location());Test.assert(!r["failed"]);
    Test.assert(r["success"]>0);Test.assertEqual(r["state"],AlertLogic.NONE);
    return true;
}

(:test)
function removed_provider_migrates_and_discards_its_cached_clear(logger) {
    requestSetup();var r=Cache.load(Config.location());var now=Time.now().value();Cache.success(r,AlertLogic.NONE,now);
    r["provider"]=0;Cache.failure(r,401,now);Cache.save(r);
    Application.Properties.setValue("apiProvider",0);
    Application.getApp().onStart(null);
    Test.assertEqual(Application.Properties.getValue("apiProvider"),2);
    r=Cache.load(Config.location());Test.assertEqual(r["provider"],2);
    Test.assertEqual(r["success"],0);Test.assertEqual(r["failures"],0);
    Test.assertEqual(r["next"],0);Test.assert(r["failed"]);
    var f=openFixture();f[0].onShow();Test.assertEqual(f[2].sends,1);
    f[2].callbacks[0].invoke(200,uaRegion(31,[{"alertLevel"=>"Yellow"}]));
    Test.assertEqual(Cache.load(Config.location())["state"],AlertLogic.YELLOW);
    return true;
}

(:test)
function removed_provider_is_public_even_before_foreground_migration(logger) {
    var o=requestSetup();Application.Properties.setValue("apiProvider",0);
    var req=new MockRequest(o.method(:done));req.start(false);
    Test.assertEqual(Config.provider(),2);Test.assertEqual(req.sends,1);
    req.callbacks[0].invoke(200,uaRegion(31,null));
    Test.assertEqual(Cache.load(Config.location())["provider"],2);return true;
}

(:test)
function upgrade_preserves_official_provider_key_and_valid_cache(logger) {
    resetTest();Application.Properties.setValue("apiProvider",1);
    Application.Properties.setValue("ukraineAlarmToken","EXISTING_KEY_FIXTURE");
    var r=Cache.load(Config.location());var now=Time.now().value();
    Cache.success(r,AlertLogic.RED,now);r["sequence"]=17;Cache.save(r);
    Application.getApp().onStart(null);r=Cache.load(Config.location());
    Test.assertEqual(Config.provider(),1);Test.assertEqual(Config.token(),"EXISTING_KEY_FIXTURE");
    Test.assertEqual(r["success"],now);Test.assertEqual(r["state"],AlertLogic.RED);
    Test.assertEqual(r["sequence"],17);Test.assert(!r["failed"]);return true;
}

(:test)
function invalid_provider_settings_normalize_to_public_provider(logger) {
    var values=[0,-1,3,99];
    for(var i=0;i<values.size();i++) {
        resetTest();Application.Properties.setValue("apiProvider",values[i]);
        Application.getApp().onStart(null);
        Test.assertEqual(Application.Properties.getValue("apiProvider"),2);
        Test.assertEqual(Config.token(),"");Test.assert(!Config.needsToken());
    }
    return true;
}

(:test)
function upgrade_preserves_public_provider_cache_and_shared_request_gate(logger) {
    requestSetup();var now=Time.now().value();var r=Cache.load(Config.location());
    Cache.success(r,AlertLogic.YELLOW,now);Cache.save(r);
    Application.Storage.setValue("requestGate",{"at"=>now,"until"=>now+60,"sequence"=>8});
    Application.getApp().onStart(null);var f=openFixture();f[0].onShow();
    Test.assertEqual(f[2].sends,0);r=Cache.load(Config.location());
    Test.assertEqual(r["success"],now);Test.assertEqual(r["state"],AlertLogic.YELLOW);
    var gate=Application.Storage.getValue("requestGate") as Dictionary;
    Test.assertEqual(gate["sequence"],8);return true;
}
