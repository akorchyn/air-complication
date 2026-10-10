using Toybox.WatchUi;
using Toybox.Application;
import Toybox.Lang;
module SettingsMenu {
    function open() {
        var menu=new WatchUi.Menu2({:title=>"Air Alert settings"});
        menu.addItem(new WatchUi.MenuItem("API provider",Config.providerName(),"provider",null));
        menu.addItem(new WatchUi.MenuItem("Provider token",!Config.needsToken() ? "Not required" : Config.token().length()==0 ? "Not set" : "Configured","token",null));
        menu.addItem(new WatchUi.MenuItem("Location",Config.location()["name"],"city",null));
        menu.addItem(new WatchUi.MenuItem("Custom UID",null,"custom",null));
        menu.addItem(new WatchUi.MenuItem("Custom label",null,"label",null));
        menu.addItem(new WatchUi.MenuItem("Refresh interval",(Config.interval()/60)+" minutes","interval",null));
        menu.addItem(new WatchUi.MenuItem("Stale after",(Config.staleSeconds()/60)+" minutes","stale",null));
        WatchUi.pushView(menu,new SettingsDelegate(),WatchUi.SLIDE_UP);
    }
    function selectList(key, names as Array, values as Array) {
        var menu=new WatchUi.Menu2({:title=>key.equals("cityUid") ? "Location" : key.equals("apiProvider") ? "API provider" : "Minutes"});
        for(var i=0;i<names.size();i++) { menu.addItem(new WatchUi.MenuItem(names[i],null,values[i],null)); }
        WatchUi.pushView(menu,new PropertyListDelegate(key),WatchUi.SLIDE_UP);
    }
    function edit(key) {
        if (WatchUi has :TextPicker) {
            // Never prefill the token: the configuration menu does not reveal it.
            var initial=(key.equals("apiToken") || key.equals("ukraineAlarmToken")) ? "" : Application.Properties.getValue(key);
            WatchUi.pushView(new WatchUi.TextPicker(initial),new PropertyTextDelegate(key),WatchUi.SLIDE_UP);
        }
    }
    function changed() { Application.getApp().onSettingsChanged(); }
}
class SettingsDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() { Menu2InputDelegate.initialize(); }
    function onSelect(item) as Void {
        var id=item.getId();
        if (id.equals("provider")) { SettingsMenu.selectList("apiProvider",["alerts.in.ua","Ukraine Alarm","UA Siren (no token)"],[0,1,2]); }
        else if (id.equals("token")) { if (Config.needsToken()) { SettingsMenu.edit(Config.provider()==1 ? "ukraineAlarmToken" : "apiToken"); } }
        else if (id.equals("custom")) { SettingsMenu.edit("customUid"); }
        else if (id.equals("label")) { SettingsMenu.edit("customLabel"); }
        else if (id.equals("city")) { SettingsMenu.selectList("cityUid",LocationPresets.names(),LocationPresets.ids()); }
        else { SettingsMenu.selectList(id.equals("interval") ? "refreshMinutes" : "staleMinutes",["5","10","15","30","60"],[5,10,15,30,60]); }
    }
}
class PropertyListDelegate extends WatchUi.Menu2InputDelegate {
    var _key;
    function initialize(key) { Menu2InputDelegate.initialize();_key=key; }
    function onSelect(item) as Void {
        Application.Properties.setValue(_key,item.getId());SettingsMenu.changed();WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
class PropertyTextDelegate extends WatchUi.TextPickerDelegate {
    var _key;
    function initialize(key) { TextPickerDelegate.initialize();_key=key; }
    function onTextEntered(text as String, changed as Boolean) as Boolean {
        if (changed) {
            if (_key.equals("customLabel") && text.length()>5) { text=text.substring(0,5); }
            Application.Properties.setValue(_key,text);
            if (_key.equals("customUid")) { Application.Properties.setValue("cityUid",0); }
            SettingsMenu.changed();
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);return true;
    }
    function onCancel() as Boolean { WatchUi.popView(WatchUi.SLIDE_DOWN);return true; }
}
