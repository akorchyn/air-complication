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

(:test)
function ukrainian_text_cases_and_invalid_states(logger) {
    resetTest();Application.Properties.setValue("textLanguage",1);
    var states=[AlertLogic.NONE,AlertLogic.YELLOW,AlertLogic.RED,AlertLogic.UNKNOWN,AlertLogic.STALE];
    var expected=[
        ["Немає","Жовта","Червона","н.д.","Застар."],
        ["НЕМАЄ","ЖОВТА","ЧЕРВОНА","Н.Д.","ЗАСТАР."],
        ["немає","жовта","червона","н.д.","застар."]
    ];
    for(var style=0;style<3;style++) {
        Application.Properties.setValue("textCase",style);
        for(var i=0;i<states.size();i++) { Test.assertEqual(AlertDisplay.value(states[i]),expected[style][i]); }
        Test.assertEqual(AlertDisplay.value(99),expected[style][3]);
    }
    return true;
}

(:test)
function english_case_defaults_and_invalid_settings(logger) {
    resetTest();
    Test.assertEqual(AlertDisplay.value(AlertLogic.NONE),"CLEAR");
    Application.Properties.setValue("textCase",2);
    Test.assertEqual(AlertDisplay.value(AlertLogic.NONE),"clear");
    Test.assertEqual(AlertDisplay.value(AlertLogic.YELLOW),"yellow");
    Test.assertEqual(AlertDisplay.value(AlertLogic.RED),"red");
    Test.assertEqual(AlertDisplay.value(AlertLogic.UNKNOWN),"n/a");
    Test.assertEqual(AlertDisplay.value(AlertLogic.STALE),"stale");
    Application.Properties.setValue("textCase",1);Test.assertEqual(AlertDisplay.value(AlertLogic.RED),"RED");
    Application.Properties.setValue("textLanguage",99);Application.Properties.setValue("textCase",99);
    Test.assertEqual(AlertDisplay.value(AlertLogic.YELLOW),"YELLOW");
    Application.Properties.setValue("textLanguage",1);Test.assertEqual(AlertDisplay.value(AlertLogic.YELLOW),"Жовта");
    return true;
}

(:test)
function ukrainian_unknown_and_stale_never_show_clear(logger) {
    var r=resetTest();Application.Properties.setValue("textLanguage",1);
    for(var style=0;style<3;style++) {
        Application.Properties.setValue("textCase",style);
        var unavailable=style==1 ? "Н.Д." : "н.д.";
        r["success"]=0;Test.assertEqual(AlertDisplay.value(AlertLogic.visible(r,1000,600)),unavailable);
        Cache.success(r,AlertLogic.NONE,1000);r["failed"]=true;
        Test.assertEqual(AlertDisplay.value(AlertLogic.visible(r,1001,600)),unavailable);
        Test.assertEqual(AlertDisplay.value(AlertLogic.visible(r,1600,600)),style==1 ? "ЗАСТАР." : style==2 ? "застар." : "Застар.");
    }
    Application.Properties.setValue("displayMode",1);
    Test.assertEqual(AlertDisplay.value(AlertLogic.NONE),"🟢");
    Test.assertEqual(AlertDisplay.value(AlertLogic.YELLOW),"🟡");
    Test.assertEqual(AlertDisplay.value(AlertLogic.RED),"🔴");
    Test.assertEqual(AlertDisplay.value(AlertLogic.UNKNOWN),"?");
    Test.assertEqual(AlertDisplay.value(AlertLogic.STALE),"!");
    return true;
}

(:test)
function language_case_edits_preserve_cache_and_failure_backoff(logger) {
    var r=resetTest();var now=Time.now().value();Cache.success(r,AlertLogic.YELLOW,now);
    r["sequence"]=7;Cache.save(r);var next=r["next"];var app=Application.getApp();app._settings=app.settingsSnapshot();
    Application.Properties.setValue("textLanguage",1);app.onSettingsChanged();
    Application.Properties.setValue("textCase",2);app.onSettingsChanged();
    r=Cache.load(Config.location());
    Test.assertEqual(r["success"],now);Test.assertEqual(r["next"],next);Test.assertEqual(r["sequence"],7);Test.assert(!r["failed"]);
    Test.assertEqual(AlertDisplay.value(AlertLogic.visible(r,now,600)),"жовта");
    Cache.failure(r,429,now);Cache.save(r);next=r["next"];
    Application.Properties.setValue("textCase",1);app.onSettingsChanged();
    r=Cache.load(Config.location());Test.assertEqual(r["next"],next);Test.assertEqual(r["failures"],1);Test.assert(r["failed"]);
    Test.assertEqual(AlertDisplay.value(AlertLogic.visible(r,now,600)),"Н.Д.");
    return true;
}

(:test)
function language_case_edit_preserves_inflight_response(logger) {
    var o=requestSetup();var req=new MockRequest(o.method(:done));req.start(true);
    var r=Cache.load(Config.location());var sequence=r["sequence"];var lease=r["lease"];
    var app=Application.getApp();app._settings=app.settingsSnapshot();
    Application.Properties.setValue("textLanguage",1);Application.Properties.setValue("textCase",2);app.onSettingsChanged();
    r=Cache.load(Config.location());Test.assertEqual(r["sequence"],sequence);Test.assertEqual(r["lease"],lease);
    req.response(200,{"alerts"=>[{"location_uid"=>"31","location_type"=>"city","alert_type"=>"air_raid","alert_level"=>"red"}]});
    r=Cache.load(Config.location());Test.assert(!r["failed"]);Test.assertEqual(req.sends,1);Test.assertEqual(o.finished,1);
    Test.assertEqual(AlertDisplay.value(r["state"]),"червона");return true;
}
