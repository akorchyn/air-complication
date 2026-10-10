using Toybox.Test;
using Toybox.Application;
import Toybox.Lang;
(:test)
function ended_airraid(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location","finished_at"=>"2026-10-10T08:01:00Z"}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function invalid_alerts(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>"broken"},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function invalid_row(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[null]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function kharkiv_separate(logger) {
 Application.Properties.setValue("cityUid",1293);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"22","location_type"=>"oblast","location_oblast_uid"=>"22","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"},{"location_uid"=>"124","location_type"=>"raion","location_oblast_uid"=>"22","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,0);
 return true;
}
(:test)
function known_red_bad_row(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"},null]},Config.location());
 Test.assertEqual(got,2);
 return true;
}
(:test)
function kyiv_oblast_separate(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"14","location_type"=>"oblast","location_oblast_uid"=>"14","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,0);
 return true;
}
(:test)
function malformed_threat(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"yellow","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location","threats"=>[{"level"=>"green"}]}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function missing_alerts(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function missing_level(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function missing_uid(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"alert_type"=>"air_raid","alert_level"=>"red"}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function no_alerts(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[]},Config.location());
 Test.assertEqual(got,0);
 return true;
}
(:test)
function oblast_inheritance(logger) {
 Application.Properties.setValue("cityUid",845);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"27","location_type"=>"oblast","location_oblast_uid"=>"27","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,2);
 return true;
}
(:test)
function raion_inheritance(logger) {
 Application.Properties.setValue("cityUid",964);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"104","location_type"=>"raion","location_oblast_uid"=>"18","alert_type"=>"air_raid","alert_level"=>"yellow","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,1);
 return true;
}
(:test)
function red_city(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,2);
 return true;
}
(:test)
function red_priority(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"yellow","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"},{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,2);
 return true;
}
(:test)
function red_threat_over_yellow(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"yellow","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location","threats"=>[{"threat_type"=>"drones","level"=>"red"}]}]},Config.location());
 Test.assertEqual(got,2);
 return true;
}
(:test)
function sibling_city(logger) {
 Application.Properties.setValue("cityUid",845);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"846","location_type"=>"hromada","location_oblast_uid"=>"27","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,0);
 return true;
}
(:test)
function uid_bad_string(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31foo","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function uid_is_number(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>31,"location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,2);
 return true;
}
(:test)
function unknown_location_type(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"123","location_type"=>"unknown","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function unrelated_type(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"artillery_shelling","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,0);
 return true;
}
(:test)
function unsupported_level(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"green","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function unsupported_type(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"future_threat","alert_level"=>"yellow","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function yellow_bad_row(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"yellow","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"},null]},Config.location());
 Test.assertEqual(got,3);
 return true;
}
(:test)
function yellow_city(logger) {
 Application.Properties.setValue("cityUid",31);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"31","location_type"=>"city","location_oblast_uid"=>"0","alert_type"=>"air_raid","alert_level"=>"yellow","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,1);
 return true;
}
(:test)
function zaporizhzhia_separate(logger) {
 Application.Properties.setValue("cityUid",564);
 var got=AlertLogic.parse({"alerts"=>[{"location_uid"=>"12","location_type"=>"oblast","location_oblast_uid"=>"12","alert_type"=>"air_raid","alert_level"=>"red","started_at"=>"2026-10-10T08:00:00Z","updated_at"=>"2026-10-10T08:00:00Z","location_title"=>"Fixture location"}]},Config.location());
 Test.assertEqual(got,0);
 return true;
}
