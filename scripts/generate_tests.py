#!/usr/bin/env python3
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def mc(v):
 if v is None:return 'null'
 if isinstance(v,bool):return str(v).lower()
 if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
 if isinstance(v,list):return '['+','.join(map(mc,v))+']'
 if isinstance(v,dict):return '{'+','.join(mc(k)+'=>'+mc(x) for k,x in v.items())+'}'
 return str(v)
lines=['using Toybox.Test;','using Toybox.Application;','import Toybox.Lang;']
for file in sorted((ROOT/'tests/fixtures').glob('*.json')):
 d=json.loads(file.read_text())
 if 'expected' not in d:continue
 parser=f'ApiProvider.parse({mc(d["response"])},Config.location(),{d.get("query",d["uid"])})' if d.get('provider',0)!=0 else f'AlertLogic.parse({mc(d["response"])},Config.location())'
 lines.extend(['(:test)',f'function {file.stem}(logger) {{',f' Application.Properties.setValue("apiProvider",{d.get("provider",0)});',f' Application.Properties.setValue("cityUid",{d["uid"]});',' LocationCatalog.resolveCustom();',f' var got={parser};',f' Test.assertEqual(got,{d["expected"]});',' return true;','}'])
(ROOT/'tests/generated/Fixtures.mc').write_text('\n'.join(lines)+'\n')
