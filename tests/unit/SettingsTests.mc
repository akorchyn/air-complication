using Toybox.Application;
using Toybox.Test;

(:test)
function settings_return_updates_provider_and_token_requirement(logger) {
    resetTest();Application.Properties.setValue("apiToken","");
    var menu=new AirAlertSettingsMenu();
    Test.assertEqual(menu.getItem(menu.findItemById("provider")).getSubLabel(),"alerts.in.ua");
    Application.Properties.setValue("apiProvider",2);
    // Exercise the lifecycle used when a picker pops, on the SAME menu object.
    menu.onShow();
    Test.assertEqual(menu.getItem(menu.findItemById("provider")).getSubLabel(),"UA Siren");
    Test.assertEqual(menu.getItem(menu.findItemById("token")).getSubLabel(),"Not required");
    Application.Properties.setValue("apiProvider",1);
    Application.Properties.setValue("ukraineAlarmToken","FIXTURE_ONLY");
    menu.onShow();
    Test.assertEqual(menu.getItem(menu.findItemById("provider")).getSubLabel(),"Ukraine Alarm");
    Test.assertEqual(menu.getItem(menu.findItemById("token")).getSubLabel(),"Configured");
    return true;
}

(:test)
function settings_return_updates_location_and_intervals(logger) {
    resetTest();var menu=new AirAlertSettingsMenu();
    Application.Properties.setValue("cityUid",845);
    Application.Properties.setValue("refreshMinutes",30);
    Application.Properties.setValue("staleMinutes",15);
    Application.Properties.setValue("customUid","964");
    Application.Properties.setValue("customLabel","ODESA");
    menu.onShow();
    Test.assertEqual(menu.getItem(menu.findItemById("city")).getSubLabel(),"Lviv city");
    Test.assertEqual(menu.getItem(menu.findItemById("interval")).getSubLabel(),"30 minutes");
    Test.assertEqual(menu.getItem(menu.findItemById("stale")).getSubLabel(),"15 minutes");
    Test.assertEqual(menu.getItem(menu.findItemById("custom")).getSubLabel(),"964");
    Test.assertEqual(menu.getItem(menu.findItemById("label")).getSubLabel(),"ODESA");
    Application.Properties.setValue("displayMode",1);menu.onShow();
    Test.assertEqual(menu.getItem(menu.findItemById("display")).getSubLabel(),"Status dots");
    return true;
}

(:test)
function settings_return_updates_language_and_case(logger) {
    resetTest();var menu=new AirAlertSettingsMenu();
    Test.assertEqual(menu.getItem(menu.findItemById("language")).getSubLabel(),"English");
    Test.assertEqual(menu.getItem(menu.findItemById("case")).getSubLabel(),"Default");
    Application.Properties.setValue("textLanguage",1);Application.Properties.setValue("textCase",2);menu.onShow();
    Test.assertEqual(menu.getItem(menu.findItemById("language")).getSubLabel(),"Українська");
    Test.assertEqual(menu.getItem(menu.findItemById("case")).getSubLabel(),"lowercase");
    Application.Properties.setValue("textCase",1);menu.onShow();
    Test.assertEqual(menu.getItem(menu.findItemById("case")).getSubLabel(),"UPPERCASE");return true;
}
