using Toybox.Application;
using Toybox.Time;
using Toybox.Test;

(:test)
function display_mode_maps_all_states_and_rejects_invalid_setting(logger) {
    resetTest();
    Test.assertEqual(AlertDisplay.value(AlertLogic.NONE),"CLEAR");
    Application.Properties.setValue("displayMode",1);
    Test.assertEqual(AlertDisplay.value(AlertLogic.NONE),"🟢");
    Test.assertEqual(AlertDisplay.value(AlertLogic.YELLOW),"🟡");
    Test.assertEqual(AlertDisplay.value(AlertLogic.RED),"🔴");
    Test.assertEqual(AlertDisplay.value(AlertLogic.UNKNOWN),"?");
    Test.assertEqual(AlertDisplay.value(AlertLogic.STALE),"!");
    Application.Properties.setValue("displayMode",99);
    Test.assertEqual(AlertDisplay.value(AlertLogic.NONE),"CLEAR");
    return true;
}

(:test)
function dot_mode_never_shows_green_for_failed_or_stale_check(logger) {
    var r=resetTest();Application.Properties.setValue("displayMode",1);
    Test.assertEqual(AlertDisplay.value(AlertLogic.visible(r,1000,600)),"?");
    Cache.success(r,AlertLogic.NONE,1000);
    Test.assertEqual(AlertDisplay.value(AlertLogic.visible(r,1599,600)),"🟢");
    Test.assertEqual(AlertDisplay.value(AlertLogic.visible(r,1600,600)),"!");
    r["failed"]=true;
    Test.assertEqual(AlertDisplay.value(AlertLogic.visible(r,1001,600)),"?");
    return true;
}

(:test)
function mode_change_preserves_cache_schedule_and_request_generation(logger) {
    var r=resetTest();var now=Time.now().value();
    Cache.success(r,AlertLogic.NONE,now);r["sequence"]=7;Cache.save(r);
    var next=r["next"];var app=Application.getApp();
    app._settings=app.settingsSnapshot();
    Application.Properties.setValue("displayMode",1);app.onSettingsChanged();
    r=Cache.load(Config.location());
    Test.assertEqual(r["success"],now);Test.assert(!r["failed"]);
    Test.assertEqual(r["next"],next);Test.assertEqual(r["sequence"],7);
    Test.assertEqual(AlertDisplay.value(AlertLogic.visible(r,now,600)),"🟢");
    // Data-affecting edits still invalidate in-flight generations.
    Application.Properties.setValue("apiToken","CHANGED_FIXTURE_ONLY");app.onSettingsChanged();
    r=Cache.load(Config.location());Test.assert(r["failed"]);Test.assertEqual(r["sequence"],0);
    return true;
}

(:test)
function dot_mode_change_does_not_reset_failure_backoff(logger) {
    var r=resetTest();var now=Time.now().value();
    Cache.failure(r,429,now);Cache.save(r);var next=r["next"];
    var app=Application.getApp();app._settings=app.settingsSnapshot();
    Application.Properties.setValue("displayMode",1);app.onSettingsChanged();
    r=Cache.load(Config.location());
    Test.assertEqual(r["next"],next);Test.assertEqual(r["failures"],1);Test.assert(r["failed"]);
    return true;
}
