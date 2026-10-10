using Toybox.Application;
import Toybox.Lang;
using Toybox.Test;
function resetTest() as Dictionary {
 Application.Properties.setValue("apiProvider",0);
 Application.Properties.setValue("cityUid",31);
 Application.Properties.setValue("staleMinutes",10);
 Application.Properties.setValue("refreshMinutes",5);
 Application.Storage.deleteValue("cache");
 return Cache.load(Config.location());
}
(:test)
function first_launch_without_token(logger) {
 var r=resetTest();Application.Properties.setValue("apiToken","");
 Test.assertEqual(AlertLogic.visible(r,1000,600),AlertLogic.UNKNOWN);return true;
}
(:test)
function stale_boundary_and_clock_rollback(logger) {
 var r=resetTest();Cache.accept(r,200,{"alerts"=>[]},Config.location(),1000);
 Test.assertEqual(AlertLogic.visible(r,1599,600),AlertLogic.NONE);
 Test.assertEqual(AlertLogic.visible(r,1600,600),AlertLogic.STALE);
 Test.assertEqual(AlertLogic.visible(r,999,600),AlertLogic.UNKNOWN);return true;
}
(:test)
function switching_city_invalidates_cache(logger) {
 var r=resetTest();Cache.accept(r,200,{"alerts"=>[]},Config.location(),1000);Cache.save(r);
 Application.Properties.setValue("cityUid",845);r=Cache.load(Config.location());
 Test.assertEqual(r["success"],0);Test.assertEqual(r["uid"],845);
 Test.assertEqual(AlertLogic.visible(r,1001,600),AlertLogic.UNKNOWN);return true;
}
(:test)
function http_failures_never_clear(logger) {
 var codes=[304,401,403,429,500,503,-104,-300,-400,-402,-403,-1004];
 for(var i=0;i<codes.size();i++) {
  var r=resetTest();Cache.accept(r,200,{"alerts"=>[]},Config.location(),1000);
  Test.assert(!Cache.accept(r,codes[i],null,Config.location(),1001));
  Test.assertEqual(AlertLogic.visible(r,1001,600),AlertLogic.UNKNOWN);
  Test.assertEqual(r["success"],1000);Test.assert(r["next"]>=1301);
 }
 return true;
}
(:test)
function recovery_after_reconnection(logger) {
 var r=resetTest();Cache.failure(r,-104,1000);
 Test.assert(!Cache.canRequest(r,1001,true));Test.assert(Cache.canRequest(r,1300,true));
 Cache.accept(r,200,{"alerts"=>[]},Config.location(),1300);
 Test.assertEqual(AlertLogic.visible(r,1300,600),AlertLogic.NONE);Test.assertEqual(r["failures"],0);return true;
}
(:test)
function overlapping_requests_and_manual_floor(logger) {
 var r=resetTest();r["request"]=1000;r["lease"]=1060;
 Test.assert(!Cache.canRequest(r,1001,true));Test.assert(!Cache.canRequest(r,1059,true));
 Test.assert(Cache.canRequest(r,1060,true));r["next"]=2000;
 Test.assert(!Cache.canRequest(r,1060,false));Test.assert(Cache.canRequest(r,1060,true));return true;
}
(:test)
function rate_limit_backoff(logger) {
 Test.assertEqual(AlertLogic.backoff(429,1),900);Test.assertEqual(AlertLogic.backoff(500,1),300);
 Test.assertEqual(AlertLogic.backoff(500,2),600);Test.assertEqual(AlertLogic.backoff(500,8),3600);
 Test.assertEqual(AlertLogic.backoff(401,1),3600);return true;
}
(:test)
function custom_location_is_official_and_exact(logger) {
 var p=LocationCatalog.parents(332);Test.assertEqual(p[0],9);Test.assertEqual(p[1],44);
 Test.assertEqual(LocationCatalog.parents(31)[0],0);
 Test.assert(LocationCatalog.parents(999999)==null);
 Application.Properties.setValue("cityUid",0);Application.Properties.setValue("customUid","332");
 LocationCatalog.resolveCustom();Test.assertEqual(Config.location()["uid"],332);return true;
}
(:test)
function intervals_are_validated(logger) {
 var values=[5,10,15,30,60];
 for(var i=0;i<values.size();i++) { Application.Properties.setValue("refreshMinutes",values[i]);Test.assertEqual(Config.interval(),values[i]*60); }
 Application.Properties.setValue("refreshMinutes",1);Test.assertEqual(Config.interval(),300);return true;
}

(:test)
function corrupted_cache_is_unknown(logger) {
 resetTest();Application.Storage.setValue("cache",{"schema"=>1,"uid"=>31});
 var r=Cache.load(Config.location());Test.assertEqual(r["success"],0);return true;
}
