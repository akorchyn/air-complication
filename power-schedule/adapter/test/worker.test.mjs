import {test} from 'node:test';
import assert from 'node:assert/strict';
import {normalize, wallTime, createHandler, PROFILES} from '../src/worker.mjs';
import {profile, now, raw} from './fixtures.mjs';

const path = 'https://adapter.example/v1/schedule?region=25&dso=902&group=19.1';
const request = () => new Request(path);
test('projection returns only selected group, provenance and small numeric slots', () => {
  const d = normalize(raw(), profile, '19.1', now);
  assert.equal(d.group, '19.1'); assert.equal(d.checkedAt, now); assert.equal(d.days[0][3],1);
  assert.deepEqual(d.days[0][4][1], [now-3600,now+3600,1,480,600]);
  assert(!JSON.stringify(d).includes('20.1')); assert(Buffer.byteLength(JSON.stringify(d))<1024);
});
for (const [date, minute, expected] of [
  ['2026-01-15T00:00:00+03:00',480,'2026-01-15T06:00:00Z'],
  ['2026-07-15T00:00:00+02:00',480,'2026-07-15T05:00:00Z'],
  ['2026-03-29T00:00:00+02:00',480,'2026-03-29T05:00:00Z'],
  ['2026-10-25T00:00:00+03:00',480,'2026-10-25T06:00:00Z'],
  ['2026-03-29T00:00:00+02:00',1440,'2026-03-29T21:00:00Z'],
  ['2026-10-25T00:00:00+03:00',1440,'2026-10-25T22:00:00Z'],
  ['2026-10-25T00:00:00+03:00',195,'2026-10-25T00:15:00Z'],
  ['2026-03-29T00:00:00+02:00',195,'2026-03-29T01:15:00Z'],
]) test(`Kyiv wall time ${date} + ${minute}`, () => assert.equal(wallTime(date,minute),Date.parse(expected)/1000));
for (const [status, code] of [['WaitingForSchedule',2],['EmergencyShutdowns',3],['NewStatus',4]]) {
  test(status+' never implies scheduled ON', () => {
    const r=raw();r['19.1'].today.status=status;
    const d=normalize(r,profile,'19.1',now);assert.equal(d.days[0][3],code);assert.deepEqual(d.days[0][4],[]);
  });
}
test('NoOutages with empty slots is explicit whole-day coverage', () => {
  const r=raw();r['19.1'].today.status='NoOutages';r['19.1'].today.slots=[];
  const d=normalize(r,profile,'19.1',now);assert.equal(d.days[0][4][0][2],0);assert.equal(d.days[0][4][0][4],1440);
});
test('touching intervals of same type merge', () => {
  const r=raw();r['19.1'].today.slots=[{start:0,end:60,type:'Definite'},{start:60,end:120,type:'Definite'}];
  const d=normalize(r,profile,'19.1',now);assert.equal(d.days[0][4].length,1);assert.equal(d.days[0][4][0][4],120);
});
for (const [name, mutate] of [
  ['invalid day',r=>r['19.1'].today=null], ['invalid date',r=>r['19.1'].today.date='2026-02-30T00:00:00Z'],
  ['invalid slot',r=>r['19.1'].today.slots[0].type='Maybe'], ['negative minute',r=>r['19.1'].today.slots[0].start=-1],
  ['oversized minute',r=>r['19.1'].today.slots[0].end=1441], ['reversed interval',r=>r['19.1'].today.slots[0].start=481],
  ['overlap',r=>r['19.1'].today.slots[1].start=400], ['missing slots',r=>delete r['19.1'].today.slots],
  ['future update',r=>r['19.1'].updatedOn='2028-01-01T00:00:00Z'],
  ['contradictory NoOutages',r=>r['19.1'].today.status='NoOutages'],
]) test(name+' rejected',()=>{
  const r=raw();mutate(r);
  if(name==='invalid day') { r['19.1'].tomorrow=null; }
  assert.throws(()=>normalize(r,profile,'19.1',now));
});
test('missing group rejected',()=>assert.throws(()=>normalize(raw(),profile,'61.1',now)));
test('maximum supported 64 half-open slots per day stays under 8 KiB',()=>{
  const r=raw();r['19.1'].today.slots=Array.from({length:64},(_,i)=>({start:i*20,end:(i+1)*20,type:i%2?'Definite':'NotPlanned'}));
  const d=normalize(r,profile,'19.1',now);assert(Buffer.byteLength(JSON.stringify(d))<8192);
});
test('60 source groups still produce same one-group response',()=>{
  const r=raw();for(let i=1;i<=60;i++)r[i+'.1']=structuredClone(r['19.1']);
  assert(Buffer.byteLength(JSON.stringify(r))>20000);
  assert(Buffer.byteLength(JSON.stringify(normalize(r,profile,'19.1',now)))<1024);
});
test('HTTP handler fetches exact official route, with no upstream credentials',async()=>{
  const handler=createHandler({now:()=>now,fetcher:async(url,options)=>{
    assert.equal(url,'https://app.yasno.ua/api/blackout-service/public/shutdowns/regions/25/dsos/902/planned-outages');
    assert.equal(options.headers.Authorization,undefined);return Response.json(raw());
  }});
  const response=await handler(request());assert.equal(response.status,200);assert.equal((await response.json()).group,'19.1');
});
test('optional access key enforced before network',async()=>{
  let calls=0;const handler=createHandler({fetcher:async()=>{calls++;return Response.json(raw());},now:()=>now});
  assert.equal((await handler(request(),{ACCESS_TOKEN:'private'})).status,401);assert.equal(calls,0);
  const req=new Request(path,{headers:{Authorization:'Bearer private'}});
  assert.equal((await handler(req,{ACCESS_TOKEN:'private'})).status,200);
});
test('unknown region/provider and malformed group rejected before network',async()=>{
  const handler=createHandler({fetcher:()=>{throw Error('must not fetch');}});
  for(const p of [path.replace('region=25','region=99'),path.replace('dso=902','dso=303'),path.replace('group=19.1','group=../')]) assert.equal((await handler(new Request(p))).status,400);
});
test('HTTP errors, timeout and invalid JSON never become empty/no-outages',async()=>{
  for(const fetcher of [async()=>new Response('',{status:429}),async()=>new Response('broken'),async()=>{throw Error('timeout');}]) {
    const response=await createHandler({fetcher,now:()=>now})(request());assert.equal(response.status,503);
    assert.equal((await response.json()).days,undefined);
  }
});
test('cache retains original checkedAt instead of revalidating old data',async()=>{
  const store=new Map();let calls=0;let clock=now;
  const cache={match:async k=>store.get(k)?.clone(),put:async(k,v)=>store.set(k,v)};
  const handler=createHandler({cache,now:()=>clock,fetcher:async()=>{calls++;return Response.json(raw());}});
  await handler(request());clock+=30;const d=await (await handler(request())).json();
  assert.equal(d.checkedAt,now);assert.equal(calls,1);clock+=31;await handler(request());assert.equal(calls,2);
});
test('missing group returns 404, never a different group',async()=>{
  const response=await createHandler({fetcher:async()=>Response.json(raw()),now:()=>now})(new Request(path.replace('19.1','99.1')));
  assert.equal(response.status,404);
});
test('catalog contains only independently verified region/provider pairs',async()=>assert.deepEqual(PROFILES.map(p=>[p.region,p.dso]),[[25,902],[3,301],[3,303]]));
