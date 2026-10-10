#!/usr/bin/env python3
"""Generate the foreground-only official UID resolver from the documented CSV.
No request is made by default. Refresh research/locations.csv explicitly first.
"""
import csv
from collections import defaultdict
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
groups=defaultdict(list)
oblast=raion=0
for row in csv.reader((ROOT/'research/locations.csv').open()):
    if not row or not row[0].isdigit(): continue
    uid=int(row[0]); kind=row[2]
    if kind=='Область': oblast=uid; raion=0
    elif kind=='Район': raion=uid
    if kind not in ['Громада','Місто з спеціальним статусом']: continue
    parents=(0,0) if uid in [30,31,564,1293] else (oblast,raion)
    groups[parents].append(uid)
lines=['// Generated from the official location list linked by devs.alerts.in.ua.',
       '// Foreground only: the service retains just the selected parent IDs.',
       'using Toybox.Application;','import Toybox.Lang;',
       'module LocationCatalog {',
       ' function parents(id) as Array or Null {','  var key="|"+id+"|";']
for (ob,ra),uids in sorted(groups.items()):
    # Doubling delimiters allows exact |UID| membership at every position.
    value=''.join('|'+str(uid)+'|' for uid in sorted(uids))
    lines.append(f'  if ("{value}".find(key)!=null) {{ return [{ob},{ra}]; }}')
lines.extend(['  return null;',' }',' function resolveCustom() {',
'  if (Config.number("cityUid",31)!=0) { return; }',
'  var id=AlertLogic.uid(Application.Properties.getValue("customUid"));',
'  var p=id==null ? null : parents(id);',
'  if (p==null) { Application.Storage.deleteValue("customLocation");return; }',
'  var label=Application.Properties.getValue("customLabel");',
'  if (!(label instanceof String) || label.length()==0 || label.length()>5) { label="ALERT"; }',
'  Application.Storage.setValue("customLocation",{"uid"=>id,"oblast"=>p[0],"raion"=>p[1],"name"=>label+" ("+id+")","label"=>label,"valid"=>true});',
' }','}'])
(ROOT/'source/LocationCatalog.mc').write_text('\n'.join(lines)+'\n')
print(f'Generated {sum(map(len,groups.values()))} supported city/community UIDs')
