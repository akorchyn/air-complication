using Toybox.Test;
using Toybox.Application;
import Toybox.Lang;
(:test)
function ua_bad_uid_string(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionId"=>"31foo","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),31);
 Test.assertEqual(got,3);
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
function ua_invalid_active_alerts(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>"broken"}],Config.location(),31);
 Test.assertEqual(got,3);
 return true;
}
(:test)
function ua_invalid_alert_row(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[null]}],Config.location(),31);
 Test.assertEqual(got,3);
 return true;
}
(:test)
function ua_invalid_level_row(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionId"=>"31","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[null]}]}],Config.location(),31);
 Test.assertEqual(got,3);
 return true;
}
(:test)
function ua_invalid_levels(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionId"=>"31","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>"broken"}]}],Config.location(),31);
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
function ua_kharkiv_separate(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",1293);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"22","regionType"=>"State","activeAlerts"=>[{"regionId"=>"22","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),22);
 Test.assertEqual(got,0);
 return true;
}
(:test)
function ua_kyiv_oblast_separate(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"14","regionType"=>"State","activeAlerts"=>[{"regionId"=>"14","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),14);
 Test.assertEqual(got,0);
 return true;
}
(:test)
function ua_missing_active_alerts(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State"}],Config.location(),31);
 Test.assertEqual(got,3);
 return true;
}
(:test)
function ua_missing_level_value(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionId"=>"31","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{}]}]}],Config.location(),31);
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
function ua_missing_type(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionId"=>"31","regionType"=>"State","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),31);
 Test.assertEqual(got,3);
 return true;
}
(:test)
function ua_missing_uid(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),31);
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
function ua_numeric_uid(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",31);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"31","regionType"=>"State","activeAlerts"=>[{"regionId"=>31,"regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),31);
 Test.assertEqual(got,2);
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
function ua_raion_inheritance(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",964);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"104","regionType"=>"District","activeAlerts"=>[{"regionId"=>"104","regionType"=>"District","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),104);
 Test.assertEqual(got,2);
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
function ua_volyn_child(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",8);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"255","regionType"=>"Community","activeAlerts"=>[{"regionId"=>"255","regionType"=>"Community","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),0);
 Test.assertEqual(got,2);
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
function ua_zaporizhzhia_separate(logger) {
 Application.Properties.setValue("apiProvider",2);
 Application.Properties.setValue("cityUid",564);
 LocationCatalog.resolveCustom();
 var got=ApiProvider.parse([{"regionId"=>"12","regionType"=>"State","activeAlerts"=>[{"regionId"=>"12","regionType"=>"State","type"=>"AIR","activeAlertLevels"=>[{"alertLevel"=>"Red","reason"=>"Synthetic test only"}]}]}],Config.location(),12);
 Test.assertEqual(got,0);
 return true;
}
