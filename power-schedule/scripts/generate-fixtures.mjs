import {writeFileSync, mkdirSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {normalize} from '../adapter/src/worker.mjs';
import {raw,profile,now} from '../adapter/test/fixtures.mjs';
const root=fileURLToPath(new URL('../',import.meta.url));
const data=normalize(raw(),profile,'19.1',now);
const big=raw();
for(const key of ['today','tomorrow']) {
  big['19.1'][key].status='ScheduleApplies';
  big['19.1'][key].slots=Array.from({length:64},(_,i)=>({start:i*20,end:(i+1)*20,type:i%2?'Definite':'NotPlanned'}));
}
const large=normalize(big,profile,'19.1',now);
function mc(v) {
  if(v===null)return 'null';
  if(Array.isArray(v))return '['+v.map(mc).join(',')+']';
  if(typeof v==='object')return '{'+Object.entries(v).map(([k,x])=>mc(k)+'=>'+mc(x)).join(',')+'}';
  return JSON.stringify(v);
}
mkdirSync(root+'tests/generated',{recursive:true});
writeFileSync(root+'tests/fixtures/yasno-synthetic.json',JSON.stringify(raw(),null,2)+'\n');
writeFileSync(root+'tests/fixtures/compact-synthetic.json',JSON.stringify(data,null,2)+'\n');
writeFileSync(root+'tests/fixtures/compact-large-synthetic.json',JSON.stringify(large,null,2)+'\n');
writeFileSync(root+'tests/generated/Fixtures.mc','// Generated from synthetic fixtures, never live outage events.\n(:background)\nmodule PowerFixtures {\n const NOW='+now+';\n function payload() { return '+mc(data)+'; }\n function large() { return '+mc(large)+'; }\n'+`
 function current(now, big) {
  var d=big ? large() : payload();var delta=now-d["checkedAt"];d["checkedAt"]=now;d["updatedAt"]=now-900;
  for(var i=0;i<d["days"].size();i++) {
   var day=d["days"][i];day[1]+=delta;day[2]+=delta;
   for(var j=0;j<day[4].size();j++) { day[4][j][0]+=delta;day[4][j][1]+=delta; }
  }return d;
 }
}\n`);
