// API contract/timezone semantics adapted from denysdovhan/ha-yasno-outages
// (MIT, 88f33db22cdddf4336937f4e15817792672c3d0f). See THIRD-PARTY-LICENSE.txt.
export const PROFILES = [
  {region: 25, dso: 902, name: 'Kyiv / DTEK'},
  {region: 3, dso: 301, name: 'Dnipro / DnEM'},
  {region: 3, dso: 303, name: 'Dnipro / CEK'},
];
const BASE = 'https://app.yasno.ua/api/blackout-service/public/shutdowns/';
const TYPES = {NotPlanned: 0, Definite: 1};
const STATES = {NoOutages: 0, ScheduleApplies: 1, WaitingForSchedule: 2, EmergencyShutdowns: 3};
const kyiv = new Intl.DateTimeFormat('en-GB', {
  timeZone: 'Europe/Kyiv', year: 'numeric', month: '2-digit', day: '2-digit',
  hour: '2-digit', minute: '2-digit', second: '2-digit', hourCycle: 'h23',
});
function parts(epoch) {
  return Object.fromEntries(kyiv.formatToParts(new Date(epoch * 1000))
    .filter(p => p.type !== 'literal').map(p => [p.type, Number(p.value)]));
}
function utcParts(p) { return Date.UTC(p.year, p.month - 1, p.day, p.hour || 0, p.minute || 0, p.second || 0) / 1000; }
function civil(date) {
  if (typeof date !== 'string' || !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$/.test(date)) throw Error('Invalid schedule date');
  const ymd = date.slice(0, 10);
  if (!Number.isFinite(Date.parse(date)) || new Date(ymd).toISOString().slice(0, 10) !== ymd) throw Error('Invalid schedule date');
  return ymd;
}
// Source minutes are Kyiv wall time, NOT elapsed seconds from a fixed-offset
// midnight. Choose fold=0 in a repeated hour, matching Python zoneinfo in HA.
// For nonexistent spring times, Python fold=0 uses the pre-transition offset.
export function wallTime(date, minutes) {
  const ymd = civil(date);
  if (!Number.isInteger(minutes) || minutes < 0 || minutes > 1440) throw Error('Invalid minutes');
  const nominal = Date.parse(ymd + 'T00:00:00Z') / 1000 + minutes * 60;
  const offsets = new Set([-86400, 0, 86400].map(delta => utcParts(parts(nominal + delta)) - (nominal + delta)));
  const candidates = [...offsets].map(offset => nominal - offset);
  const valid = candidates.filter(epoch => utcParts(parts(epoch)) === nominal);
  return valid.length ? Math.min(...valid) : Math.max(...candidates);
}
function day(raw) {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) throw Error('Invalid day');
  const date = civil(raw.date), start = wallTime(raw.date, 0), end = wallTime(raw.date, 1440);
  const status = Object.hasOwn(STATES, raw.status) ? STATES[raw.status] : 4;
  if (status >= 2) return [date, start, end, status, []];
  if (!Array.isArray(raw.slots) || raw.slots.length > 64) throw Error('Invalid slots');
  let rows = raw.slots.map(slot => {
    if (!slot || !Number.isInteger(slot.start) || !Number.isInteger(slot.end) ||
        slot.start < 0 || slot.end > 1440 || slot.start >= slot.end || !Object.hasOwn(TYPES, slot.type)) throw Error('Invalid slot');
    if (status === 0 && slot.type !== 'NotPlanned') throw Error('Contradictory NoOutages');
    const a = wallTime(raw.date, slot.start), b = wallTime(raw.date, slot.end);
    if (a >= b) throw Error('Invalid DST interval');
    return [a, b, TYPES[slot.type], slot.start, slot.end];
  }).sort((a, b) => a[0] - b[0]);
  const merged = [];
  for (const row of rows) {
    const prev = merged.at(-1);
    if (prev && prev[1] > row[0]) throw Error('Overlapping slots');
    if (prev && prev[1] === row[0] && prev[2] === row[2]) { prev[1] = row[1]; prev[4] = row[4]; }
    else merged.push(row);
  }
  if (status === 0) rows = [[start, end, 0, 0, 1440]];
  else rows = merged; // Uncovered intervals remain UNKNOWN on the watch.
  return [date, start, end, status, rows];
}
export function normalize(raw, profile, group, checkedAt) {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw) || !Object.hasOwn(raw, group)) throw Error('Group unavailable');
  const selected = raw[group];
  if (!selected || typeof selected !== 'object') throw Error('Invalid group');
  const updatedAt = Math.floor(Date.parse(selected.updatedOn) / 1000);
  if (!Number.isInteger(updatedAt) || updatedAt <= 0 || updatedAt > checkedAt + 300) throw Error('Invalid source timestamp');
  const days = ['today', 'tomorrow'].filter(key => selected[key] != null).map(key => day(selected[key])).sort((a,b) => a[1] - b[1]);
  if (!days.length || (days.length === 2 && days[0][2] > days[1][1])) throw Error('Invalid day coverage');
  const p = parts(updatedAt), pad = n => String(n).padStart(2, '0');
  const result = {schema: 1, region: profile.region, dso: profile.dso, group, checkedAt, updatedAt,
    updatedLabel: `${pad(p.day)}/${pad(p.month)} ${pad(p.hour)}:${pad(p.minute)}`, days};
  // The hard output bound is part of the watch's background-memory contract.
  if (JSON.stringify(result).length > 8192) throw Error('Projected response too large');
  return result;
}
function json(body, status = 200) {
  return new Response(JSON.stringify(body), {status, headers: {'Content-Type': 'application/json', 'Cache-Control': 'no-store'}});
}
async function boundedJson(response) {
  if (Number(response.headers.get('Content-Length')) > 1048576) throw Error('Upstream response too large');
  const reader = response.body.getReader(); const chunks = []; let size = 0;
  try {
    for (;;) {
      const {done, value} = await reader.read(); if (done) break;
      size += value.length; if (size > 1048576) throw Error('Upstream response too large'); chunks.push(value);
    }
  } finally { await reader.cancel(); }
  const bytes = new Uint8Array(size); let at = 0;
  for (const chunk of chunks) { bytes.set(chunk, at); at += chunk.length; }
  return JSON.parse(new TextDecoder().decode(bytes));
}
export function createHandler({fetcher = globalThis.fetch, cache = null, now = () => Math.floor(Date.now() / 1000)} = {}) {
  const inFlight = new Map();
  async function schedules(profile) {
    const url = `${BASE}regions/${profile.region}/dsos/${profile.dso}/planned-outages`;
    const cached = cache && await cache.match(url);
    if (cached) {
      const at = Number(cached.headers.get('X-Checked-At'));
      if (at > 0 && at <= now() && now() - at < 60) return {raw: await cached.json(), at};
    }
    if (inFlight.has(url)) return inFlight.get(url);
    const promise = (async () => {
      const response = await fetcher(url, {headers: {Accept: 'application/json'}, signal: AbortSignal.timeout(15000)});
      if (!response.ok) throw Error('Upstream unavailable');
      const raw = await boundedJson(response), at = now();
      if (cache) await cache.put(url, new Response(JSON.stringify(raw), {headers: {'Cache-Control': 'public, max-age=60', 'X-Checked-At': String(at)}}));
      return {raw, at};
    })();
    inFlight.set(url, promise);
    try { return await promise; } finally { inFlight.delete(url); }
  }
  return async function handle(request, env = {}) {
    if (request.method !== 'GET') return json({error: 'GET required'}, 405);
    const url = new URL(request.url);
    if (!['/v1/schedule', '/v1/groups', '/v1/catalog'].includes(url.pathname)) return json({error: 'Not found'}, 404);
    if (env.ACCESS_TOKEN && request.headers.get('Authorization') !== `Bearer ${env.ACCESS_TOKEN}`) return json({error: 'Unauthorized'}, 401);
    if (url.pathname === '/v1/catalog') return json(PROFILES);
    const region = Number(url.searchParams.get('region')), dso = Number(url.searchParams.get('dso'));
    const profile = PROFILES.find(p => p.region === region && p.dso === dso);
    const group = url.searchParams.get('group');
    if (!profile || (url.pathname === '/v1/schedule' && !/^[1-9]\d{0,2}\.[1-9]\d?$/.test(group || ''))) return json({error: 'Invalid region, provider or group'}, 400);
    try {
      const {raw, at} = await schedules(profile);
      if (url.pathname === '/v1/groups') return json(Object.keys(raw).filter(g => /^[1-9]\d{0,2}\.[1-9]\d?$/.test(g)));
      if (!Object.hasOwn(raw, group)) return json({error: 'Group unavailable'}, 404);
      return json(normalize(raw, profile, group, at));
    } catch {
      // Never substitute empty slots or fresh timestamps after an upstream error.
      return json({error: 'Schedule unavailable'}, 503);
    }
  };
}
let handler;
export default {fetch(request, env) {
  handler ||= createHandler({cache: globalThis.caches?.default});
  return handler(request, env);
}};
