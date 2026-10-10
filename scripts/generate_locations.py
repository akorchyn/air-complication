#!/usr/bin/env python3
"""Generate presets/scopes from official CSV UIDs and provider hierarchy."""
import csv,json,re,xml.etree.ElementTree as ET
from collections import defaultdict
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
rows=[r for r in csv.reader((ROOT/'research/locations.csv').open()) if r and r[0].isdigit()]
directory=json.loads((ROOT/'research/regions-ukrainealarm.json').read_text())
provider_parents={};provider_ids=set()
def walk(nodes,oblast=0,raion=0):
 for node in nodes:
  uid=int(node['regionId']);provider_ids.add(uid);provider_parents[uid]=(oblast,raion)
  walk(node.get('regionChildIds',[]),uid if node['regionType']=='State' else oblast,uid if node['regionType']=='District' else raion)
walk(directory['states'])
regions={3:('Khmelnytskyi','KHMEL'),4:('Vinnytsia','VINNY'),5:('Rivne','RIVNE'),8:('Volyn','VOLYN'),9:('Dnipropetrovsk','DNIPR'),10:('Zhytomyr','ZHYTO'),11:('Zakarpattia','ZAKAR'),12:('Zaporizhzhia','ZAPOB'),13:('Ivano-Frankivsk','IVANO'),14:('Kyiv','KYVOB'),15:('Kirovohrad','KIROV'),16:('Luhansk','LUHAN'),17:('Mykolaiv','MYKOL'),18:('Odesa','ODESO'),19:('Poltava','POLTA'),20:('Sumy','SUMY'),21:('Ternopil','TERNO'),22:('Kharkiv','KHAOB'),23:('Kherson','KHER'),24:('Cherkasy','CHERK'),25:('Chernihiv','CHERN'),26:('Chernivtsi','CHERV'),27:('Lviv','LVVOB'),28:('Donetsk','DONET'),29:('Crimea','CRIME')}
assert set(regions)=={int(r[0]) for r in rows if r[2]=='Область'}
groups=defaultdict(list);members=defaultdict(list);oblast=raion=0
for row in rows:
 uid=int(row[0]);kind=row[2]
 # Crimea is an isolated row inserted between Volyn and its districts.
 if kind=='Область' and uid!=29:oblast=uid;raion=0
 elif kind=='Район':raion=uid
 if kind not in ['Громада','Місто з спеціальним статусом','Район']:continue
 parents=(0,0) if uid in [30,31,564,1293] else provider_parents.get(uid,(oblast,raion))
 if parents[0]:members[parents[0]].append(uid)
 if kind!='Район':groups[parents].append(uid)
def literal(x):return json.dumps(x,ensure_ascii=False,separators=(',',':'))
def ids(values):return ''.join('|'+str(uid)+'|' for uid in sorted(set(values)))
lines=['// Generated: verified CSV UIDs and provider hierarchy. Foreground only.','using Toybox.Application;','import Toybox.Lang;','module LocationCatalog {',' function parents(id) as Array or Null {','  var key="|"+id+"|";']
for (ob,ra),uids in sorted(groups.items()):lines.append(f'  if ({literal(ids(uids))}.find(key)!=null) {{ return [{ob},{ra}]; }}')
lines.extend(['  return null;',' }',' function members(id) as String or Null {'])
for uid in sorted(regions):lines.append(f'  if (id=={uid}) {{ return {literal(ids([uid]+members[uid]))}; }}')
known={int(row[0]) for row in rows};bitmap=''.join('1' if uid in known else '0' for uid in range(max(known)+1))
lines.extend(['  return null;',' }',' function uaSupported(id) {',f'  return {literal(ids(provider_ids))}.find("|"+id+"|")!=null;',' }',' function known() { return '+literal(bitmap)+'; }',' function resolveCustom() {',
'  var selected=Config.number("cityUid",31);',
'  if (selected!=0) {',
'   var scope=members(selected);',
'   if (scope!=null) { Application.Storage.setValue("resolvedScope",{"uid"=>selected,"members"=>scope,"known"=>known()}); }',
'   return;',
'  }',
'  var id=AlertLogic.uid(Application.Properties.getValue("customUid"));',
'  var p=id==null ? null : parents(id);',
'  if (p==null) { Application.Storage.deleteValue("customLocation");return; }',
'  var label=Application.Properties.getValue("customLabel");',
'  if (!(label instanceof String) || label.length()==0 || label.length()>5) { label="ALERT"; }',
'  Application.Storage.setValue("customLocation",{"uid"=>id,"oblast"=>p[0],"raion"=>p[1],"kind"=>"city","name"=>label+" ("+id+")","label"=>label,"valid"=>true,"uaSupported"=>uaSupported(id)});',
' }','}'])
(ROOT/'source/LocationCatalog.mc').write_text('\n'.join(lines)+'\n')
presets=[(31,'Kyiv city','KYIV','city',0,0),(1293,'Kharkiv city','KHARK','city',0,0),(564,'Zaporizhzhia city','ZAPOR','city',0,0),(30,'Sevastopol','SEVAS','city',0,0),(845,'Lviv city','LVIV','city',27,90),(964,'Odesa city','ODESA','city',18,104),(332,'Dnipro city','DNIPR','city',9,44)]
presets.extend((uid,name+('' if uid==29 else ' oblast'),label,'oblast',0,0) for uid,(name,label) in sorted(regions.items(),key=lambda x:x[1][0]))
lines=['// Generated presets; small metadata only in background.','import Toybox.Lang;','(:background)','module LocationPresets {',' function lookup(id) as Dictionary or Null {']
for uid,name,label,kind,ob,ra in presets:
 fields={'uid':uid,'name':name,'label':label,'kind':kind,'oblast':ob,'raion':ra,'valid':True,'uaSupported':uid==29 or uid in provider_ids}
 mc='{'+','.join(literal(k)+'=>'+('true' if v is True else 'false' if v is False else literal(v)) for k,v in fields.items())+'}'
 lines.append(f'  if (id=={uid}) {{ return {mc}; }}')
lines.extend(['  return null;',' }',f' function names() {{ return {literal([x[1] for x in presets]+["Custom UID"])}; }}',f' function ids() {{ return {literal([x[0] for x in presets]+[0])}; }}','}'])
(ROOT/'source/LocationPresets.mc').write_text('\n'.join(lines)+'\n')
names=[x[1] for x in presets]+['Custom UID'];values=[x[0] for x in presets]+[0]
root=ET.Element('strings')
for name,uid in zip(names,values):ET.SubElement(root,'string',id='Location'+str(uid)).text=name+(' ('+str(uid)+')' if uid else '')
ET.indent(root);(ROOT/'resources/locations.xml').write_text(ET.tostring(root,encoding='unicode')+'\n')
path=ROOT/'resources/settings.xml';settings=path.read_text()
entries='\n'.join('  <listEntry value="'+str(uid)+'">@Strings.Location'+str(uid)+'</listEntry>' for uid in values)
settings=re.sub(r'(<setting propertyKey="@Properties.cityUid"[^>]*><settingConfig type="list">).*?(</settingConfig></setting>)',lambda m:m.group(1)+'\n'+entries+'\n '+m.group(2),settings,flags=re.S)
path.write_text(settings)
print(f'Generated {len(presets)} presets and {sum(map(len,groups.values()))} custom city/community UIDs')
