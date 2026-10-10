using Toybox.WatchUi;
using Toybox.Application;
import Toybox.Lang;
module SettingsMenu {
    function open() {
        WatchUi.pushView(new AirAlertSettingsMenu(),new SettingsDelegate(),WatchUi.SLIDE_UP);
    }
    function refresh() {
        var view=WatchUi.getCurrentView()[0];
        if (view instanceof AirAlertSettingsMenu) { view.refreshValues(); }
    }
    function selectList(key, names as Array, values as Array) {
        var menu=new WatchUi.Menu2({:title=>key.equals("cityUid") ? "Location" : key.equals("apiProvider") ? "API provider" : key.equals("displayMode") ? "Display mode" : "Minutes"});
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
class AirAlertSettingsMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title=>"Air Alert settings"});
        addItem(new WatchUi.MenuItem("API provider",null,"provider",null));
        addItem(new WatchUi.MenuItem("Display mode",null,"display",null));
        addItem(new WatchUi.MenuItem("Provider token",null,"token",null));
        addItem(new WatchUi.MenuItem("Location",null,"city",null));
        addItem(new WatchUi.MenuItem("Custom UID",null,"custom",null));
        addItem(new WatchUi.MenuItem("Custom label",null,"label",null));
        addItem(new WatchUi.MenuItem("Refresh interval",null,"interval",null));
        addItem(new WatchUi.MenuItem("Stale after",null,"stale",null));
        refreshValues();
    }
    function onShow() as Void {
        Menu2.onShow();
        // Returning from a picker reveals this same menu instance.
        refreshValues();WatchUi.requestUpdate();
    }
    function setValue(id as String, value as String) {
        var index=findItemById(id);var item=getItem(index);
        if (item!=null) { item.setSubLabel(value);updateItem(item,index); }
    }
    function refreshValues() {
        setValue("provider",Config.providerName());
        setValue("display",Config.displayModeName());
        setValue("token",!Config.needsToken() ? "Not required" : Config.token().length()==0 ? "Not set" : "Configured");
        setValue("city",Config.location()["name"]);
        var uid=Application.Properties.getValue("customUid");
        var label=Application.Properties.getValue("customLabel");
        setValue("custom",uid instanceof String && uid.length()>0 ? uid : "Not set");
        setValue("label",label instanceof String && label.length()>0 ? label : "ALERT");
        setValue("interval",(Config.interval()/60)+" minutes");
        setValue("stale",(Config.staleSeconds()/60)+" minutes");
    }
}
class SettingsDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() { Menu2InputDelegate.initialize(); }
    function onSelect(item) as Void {
        var id=item.getId();
        if (id.equals("provider")) { SettingsMenu.selectList("apiProvider",["alerts.in.ua","Ukraine Alarm","UA Siren (no token)"],[0,1,2]); }
        else if (id.equals("display")) { SettingsMenu.selectList("displayMode",["Text","Status dots"],[0,1]); }
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
