using Toybox.Test;
using Toybox.Application;
import Toybox.Lang;
(:test)
function alerts_new_child(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",27);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"20001","location_type"=>"hromada","location_oblast_uid"=>"27","alert_type"=>"air_raid","alert_level"=>"yellow"}]},Config.location());
 Test.assertEqual(got,1);
 return true;
}
(:test)
function alerts_oblast_child(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",27);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"845","location_type"=>"hromada","location_oblast_uid"=>"27","alert_type"=>"air_raid","alert_level"=>"yellow"}]},Config.location());
 Test.assertEqual(got,1);
 return true;
}
(:test)
function alerts_oblast_foreign(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",27);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"332","location_type"=>"hromada","location_oblast_uid"=>"9","alert_type"=>"air_raid","alert_level"=>"yellow"}]},Config.location());
 Test.assertEqual(got,0);
 return true;
}
(:test)
function alerts_oblast_separate(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",22);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"1293","location_type"=>"hromada","location_oblast_uid"=>"22","alert_type"=>"air_raid","alert_level"=>"yellow"}]},Config.location());
 Test.assertEqual(got,0);
 return true;
}
(:test)
function alerts_volyn_child(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",8);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"255","location_type"=>"hromada","location_oblast_uid"=>"8","alert_type"=>"air_raid","alert_level"=>"yellow"}]},Config.location());
 Test.assertEqual(got,1);
 return true;
}
(:test)
function ended_airraid(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location","finished_at"=>"2026-10-10T08:01:00Z"}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function invalid_alerts(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>"broken"},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function invalid_row(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[null]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function kharkiv_separate(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",1293);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"22","location_type"=>"oblast","location_oblast_uid"=>"22","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"},{"location_uid"=>"124","location_type"=>"raion","location_oblast_uid"=>"22","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,0);
 return true;
}
(:test)
function known_red_bad_row(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"},null]},Config.location());
 Test.assertEqual(got,2);
 return true;
}
(:test)
function kyiv_oblast_separate(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"14","location_type"=>"oblast","location_oblast_uid"=>"14","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,0);
 return true;
}
(:test)
function malformed_threat(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"yellow","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location","threats"=>[{"level"=>"green"}]}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function missing_alerts(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function missing_level(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function missing_uid(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"alert_type"=>"air_raid","alert_level"=>"red"}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function no_alerts(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[]},Config.location());
 Test.assertEqual(got,0);
 return true;
}
(:test)
function oblast_inheritance(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",845);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"27","location_type"=>"oblast","location_oblast_uid"=>"27","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,2);
 return true;
}
(:test)
function raion_inheritance(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",964);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"104","location_type"=>"raion","location_oblast_uid"=>"18","alert_type"=>"air_raid","alert_level"=>"yellow","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,1);
 return true;
}
(:test)
function red_city(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,2);
 return true;
}
(:test)
function red_priority(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"yellow","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"},{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,2);
 return true;
}
(:test)
function red_threat_over_yellow(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"yellow","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location","threats"=>[{"threat_type"=>"drones","level"=>"red"}]}]},Config.location());
 Test.assertEqual(got,2);
 return true;
}
(:test)
function sibling_city(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",845);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"846","location_type"=>"hromada","location_oblast_uid"=>"27","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,0);
 return true;
}
(:test)
function ua_both_levels(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionId"=>"31","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Yellow","reason"=>"Synthetic test only"},{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),31);
 Test.assertEqual(got,2);
 return true;
}
(:test)
function ua_crimea_alias(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",29);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"9999","regionType"=>"State","activeAlerts"=>[{"regionId"=>"9999","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),0);
 Test.assertEqual(got,2);
 return true;
}
(:test)
function ua_empty_regional_response(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([],Config.location(),31);
 Test.assertEqual(got,3);
 return true;
}
(:test)
function ua_invalid_root(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse({"alerts"=>[]},Config.location(),31);
 Test.assertEqual(got,3);
 return true;
}
(:test)
function ua_missing_levels(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionId"=>"31","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[]}]}],Config.location(),31);
 Test.assertEqual(got,3);
 return true;
}
(:test)
function ua_new_unmapped_location(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",27);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"20001","regionType"=>"Community","activeAlerts"=>[{"regionId"=>"20001","regionType"=>"Community","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Yellow","reason"=>"Synthetic test only"}]}]}],Config.location(),0);
 Test.assertEqual(got,3);
 return true;
}
(:test)
function ua_no_alerts(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[]}],Config.location(),31);
 Test.assertEqual(got,0);
 return true;
}
(:test)
function ua_oblast_foreign(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",27);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"124","regionType"=>"District","activeAlerts"=>[{"regionId"=>"124","regionType"=>"District","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),0);
 Test.assertEqual(got,0);
 return true;
}
(:test)
function ua_oblast_parent(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",845);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"27","regionType"=>"State","activeAlerts"=>[{"regionId"=>"27","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),27);
 Test.assertEqual(got,2);
 return true;
}
(:test)
function ua_oblast_partial(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",27);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"90","regionType"=>"District","activeAlerts"=>[{"regionId"=>"90","regionType"=>"District","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Yellow","reason"=>"Synthetic test only"}]}]}],Config.location(),0);
 Test.assertEqual(got,1);
 return true;
}
(:test)
function ua_oblast_separate_city(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",22);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"1293","regionType"=>"State","activeAlerts"=>[{"regionId"=>"1293","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),0);
 Test.assertEqual(got,0);
 return true;
}
(:test)
function ua_red(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionId"=>"31","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),31);
 Test.assertEqual(got,2);
 return true;
}
(:test)
function ua_red_bad_row(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([null,{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionId"=>"31","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),0);
 Test.assertEqual(got,2);
 return true;
}
(:test)
function ua_sibling_city(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",845);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"845","regionType"=>"Community","activeAlerts"=>[{"regionId"=>"964","regionType"=>"Community","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),845);
 Test.assertEqual(got,0);
 return true;
}
(:test)
function ua_unknown_level(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionId"=>"31","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Orange","reason"=>"Synthetic test only"}]}]}],Config.location(),31);
 Test.assertEqual(got,3);
 return true;
}
(:test)
function ua_unknown_region_type(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"Null","activeAlerts"=>[]}],Config.location(),31);
 Test.assertEqual(got,3);
 return true;
}
(:test)
function ua_unknown_type(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionId"=>"31","regionType"=>"State","type"=>"NEW_TYPE","activeAlertLevels"=>[{"alertLevel"=>"Yellow","reason"=>"Synthetic test only"}]}]}],Config.location(),31);
 Test.assertEqual(got,3);
 return true;
}
(:test)
function ua_unrelated_type(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionId"=>"31","regionType"=>"State","type"=>"ARTILLERY","activeAlertLevels"=>[]}]}],Config.location(),31);
 Test.assertEqual(got,0);
 return true;
}
(:test)
function ua_wrong_region(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"14","regionType"=>"State","activeAlerts"=>[]}],Config.location(),31);
 Test.assertEqual(got,3);
 return true;
}
(:test)
function ua_yellow(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionId"=>"31","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Yellow","reason"=>"Synthetic test only"}]}]}],Config.location(),31);
 Test.assertEqual(got,1);
 return true;
}
(:test)
function ua_yellow_bad_row(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([null,{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionId"=>"31","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Yellow","reason"=>"Synthetic test only"}]}]}],Config.location(),0);
 Test.assertEqual(got,3);
 return true;
}
(:test)
function uid_bad_string(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31foo","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function uid_is_number(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>31,"location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,2);
 return true;
}
(:test)
function unknown_location_type(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"123","location_type"=>"unknown","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function unrelated_type(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"artillery_shelling","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,0);
 return true;
}
(:test)
function unsupported_level(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"green","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function unsupported_type(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"future_threat","alert_level"=>"yellow","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function yellow_bad_row(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"yellow","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"},null]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function yellow_city(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"yellow","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,1);
 return true;
}
(:test)
function zaporizhzhia_separate(logger) {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",564);
 LocationCatalog.resolveCustom();
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"12","location_type"=>"oblast","location_oblast_uid"=>"12","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,0);
 return true;
}
