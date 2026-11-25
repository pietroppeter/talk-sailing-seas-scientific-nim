// The map editor (maps/editor.nim builds the page): the chart of maps/chart.nim redrawn in the
// browser from the same data, with handles to move everything, and the json the deck reads.
{
const W = 960, H = 540;
const NAMES = DATA.names;
const ISLES = DATA.islands;
const MAGENTA = "#b0167a", INK = "#1f2a33", DEPTHLINE = "#6f93b0";
const SAMPLE_TEXTS = [ // drafts by Claude, to be rewritten by Pietro
  "Seven islands off the mainland, sailed clockwise. Each island is drawn at its own scale; soundings in metres.",
  "First landfall. The passage most sailors come for: code that reads like Python and runs like C.",
  "Inhabited: crews of bioinformaticians and lattice physicists made port here and stayed. Ask for their logbooks.",
  "Well charted waters: tensors, data frames and plots. A small crew keeps the beacons lit; mind the rocks where the charts end.",
  "Bridges to Python, C and JavaScript. Ships of any flag may call here and leave with their cargo.",
  "Operators and units of your own making. Macros shape this coast: read the signs before going ashore.",
  "The same app sailed twice: once in Shiny, once compiled to JavaScript. Light winds, quick crossing.",
  "The home port of this chart: notebooks as plain Nim files, built into pages and slides.",
  "Landfall. Back on the mainland, the hold full of samples. Fair winds.",
];

// --- the model: the json of the arrangement -------------------------------------------------
const clone = o => JSON.parse(JSON.stringify(o));
function withDefaults(j) {
  j = clone(j);
  j.format = "voyage-map/1"; j.w = W; j.h = H;
  j.portolano = j.portolano || {};
  j.portolano.box = j.portolano.box || [672, 412, 272, 112];
  j.portolano.texts = j.portolano.texts || SAMPLE_TEXTS.slice();
  while (j.portolano.texts.length < 9) j.portolano.texts.push("");
  j.agenda = j.agenda || {};
  if (j.agenda.y == null) j.agenda.y = 522;
  for (const isl of j.islands) { isl.near = isl.near || []; isl.rotate = isl.rotate || 0; isl.note = isl.note || ""; }
  return j;
}
let S = withDefaults(DATA.defaults);
try {
  const saved = localStorage.getItem("voyage-map-editor");
  if (saved) S = withDefaults(JSON.parse(saved));
} catch (e) { /* no storage: start from the deck's map */ }

// --- math, the same as maps/geometry.nim and maps/isole.nim ---------------------------------
const rad = d => d * Math.PI / 180;
const f1 = x => (Math.round(x * 10) / 10).toFixed(1);
const r2 = x => Math.round(x * 100) / 100;
function valueNoise(x, y) {
  const h = (i, j) => { const s = Math.sin(i * 127.1 + j * 311.7) * 43758.5453; return s - Math.floor(s); };
  const i = Math.floor(x), j = Math.floor(y);
  let tx = x - i, ty = y - j;
  tx = tx * tx * (3 - 2 * tx); ty = ty * ty * (3 - 2 * ty);
  const a = h(i, j) * (1 - tx) + h(i + 1, j) * tx;
  const b = h(i, j + 1) * (1 - tx) + h(i + 1, j + 1) * tx;
  return a * (1 - ty) + b * ty;
}
function fbm(x, y, oct = 4) {
  let amp = 0.5, freq = 1, norm = 0, r = 0;
  for (let o = 0; o < oct; o++) { r += amp * valueNoise(x * freq + o * 17.3, y * freq - o * 9.1); norm += amp; amp *= 0.5; freq *= 2.1; }
  return r / norm;
}
function coastPoint(o, angle, upk, at, p) {
  const kLon = 111.32 * Math.cos(rad(o[1])), a = rad(-angle);
  const e = (p[0] - o[0]) * kLon, n = (p[1] - o[1]) * 110.57;
  return [at[0] + upk * (e * Math.cos(a) - n * Math.sin(a)), at[1] - upk * (e * Math.sin(a) + n * Math.cos(a))];
}
function coastPolygon(lonLat, origin, angle, upk, at, endDown, rough = 4, reach = 60) {
  const line = lonLat.map(p => coastPoint(origin, angle, upk, at, p));
  const wander = (p, q) => {
    const out = [], l = Math.hypot(q[0] - p[0], q[1] - p[1]), n = Math.max(1, Math.floor(l / 4));
    for (let j = 0; j < n; j++) {
      const t = j / n, m = [p[0] + t * (q[0] - p[0]), p[1] + t * (q[1] - p[1])];
      const off = rough * Math.min(1, 4 * t * (1 - t) + 0.3) * (2 * fbm(m[0] / 30, m[1] / 30, 4) - 1);
      out.push([m[0] - off * (q[1] - p[1]) / l, m[1] + off * (q[0] - p[0]) / l]);
    }
    return out;
  };
  const start = [-30, line[0][1] + reach];
  const last = line[line.length - 1];
  const stop = endDown ? [last[0] + reach * 0.3, H + 30] : [W + 30, last[1] + reach];
  const res = wander(start, line[0]).concat(line, wander(last, stop));
  if (!endDown) res.push([W + 30, H + 30]);
  res.push(stop, [-30, H + 30]);
  return res;
}
const turn = (p, a) => [p[0] * Math.cos(a) - p[1] * Math.sin(a), -(p[0] * Math.sin(a) + p[1] * Math.cos(a))];
function outlineKm(isl) { const r = []; for (let k = 0; k < isl.x.length; k++) r.push([isl.x[k], isl.y[k]]); return r; }
function placement(isl, center, size, rotate) {
  const a = rad(-rotate); let lo = [Infinity, Infinity], hi = [-Infinity, -Infinity];
  for (const p of outlineKm(isl)) { const q = turn(p, a); lo = [Math.min(lo[0], q[0]), Math.min(lo[1], q[1])]; hi = [Math.max(hi[0], q[0]), Math.max(hi[1], q[1])]; }
  return { a, k: size / Math.max(hi[0] - lo[0], hi[1] - lo[1]), mid: [(lo[0] + hi[0]) / 2, (lo[1] + hi[1]) / 2], center };
}
function toMap(pl, km) { const q = turn(km, pl.a); return [pl.center[0] + (q[0] - pl.mid[0]) * pl.k, pl.center[1] + (q[1] - pl.mid[1]) * pl.k]; }
function centroidKm(isl) {
  const o = outlineKm(isl), n = o.length; let a = 0, cx = 0, cy = 0;
  for (let i = 0; i < n; i++) { const p = o[i], q = o[(i + 1) % n], f = p[0] * q[1] - q[0] * p[1]; a += f; cx += (p[0] + q[0]) * f; cy += (p[1] + q[1]) * f; }
  return a === 0 ? [0, 0] : [cx / (3 * a), cy / (3 * a)];
}
function kmOf(isl, ll) { const c = centroidKm(isl); return [(ll[0] - isl.clon) * 111.32 * Math.cos(rad(isl.clat)) + c[0], (ll[1] - isl.clat) * 110.57 + c[1]]; }
function offsetKm(isl, other) {
  const kLon = 111.32 * Math.cos(rad(isl.clat)), c1 = centroidKm(isl), c2 = centroidKm(other);
  return [(other.clon - isl.clon) * kLon - c2[0] + c1[0], (other.clat - isl.clat) * 110.57 - c2[1] + c1[1]];
}

// --- the geometry of the arrangement ----------------------------------------------------------
function geometry() {
  const c = S.coast;
  const lonLat = DATA.coast.slice(c.from || 0, (c.to == null ? DATA.muggia : c.to) + 1);
  const origin = DATA.coast[DATA.triesteAt];
  const coast = coastPolygon(lonLat, origin, c.angle, c.scale, c.trieste, c.openEast !== false);
  const islands = S.islands.map((s, i) => {
    const isl = ISLES[s.real];
    const pl = placement(isl, s.center, s.size, s.rotate);
    const poly = outlineKm(isl).map(p => toMap(pl, p));
    let halfH = 0; for (const p of poly) halfH = Math.max(halfH, Math.abs(p[1] - s.center[1]));
    const islets = s.near.map(name => { const o = offsetKm(isl, ISLES[name]); return outlineKm(ISLES[name]).map(p => toMap(pl, [o[0] + p[0], o[1] + p[1]])); });
    const pick = DATA.picks.find(p => p.real === s.real);
    return { slot: s, poly, islets, pl, r: (halfH + 4) / 0.8, elevation: isl.elevation, port: toMap(pl, kmOf(isl, pick.port)) };
  });
  const lands = [coast]; for (const g of islands) lands.push(g.poly);
  for (const g of islands) for (const p of g.islets) lands.push(p);
  const groups = [{ key: JSON.stringify(c), polys: [coast] }].concat(islands.map(g => ({
    key: JSON.stringify([g.slot.real, g.slot.center, g.slot.size, g.slot.rotate, g.slot.near]), polys: [g.poly, ...g.islets] })));
  return { coast, islands, lands, origin, groups };
}
function route() {
  const r = [S.setOut.anchor]; for (const s of S.islands) r.push(s.anchor); r.push(S.landfall.anchor); return r;
}
function leg(k) { const r = route(); return [r[k]].concat(S.legs[k] || [], [r[k + 1]]); }
function routePolyline(upTo) {
  const r = route(), last = upTo == null ? r.length - 1 : Math.min(upTo, r.length - 1), out = [];
  for (let k = 0; k < last; k++) { const l = leg(k); out.push(...(k === 0 ? l : l.slice(1))); }
  return out;
}
const svgPath = (poly, closed = true) => poly.map((p, i) => (i ? " L" : "M") + f1(p[0]) + "," + f1(p[1])).join("") + (closed && poly.length ? " Z" : "");

// --- the distance field, with boxes to skip far coasts -------------------------------------------
function prepare(lands) {
  return lands.map(poly => {
    const n = poly.length, xs = new Float64Array(n), ys = new Float64Array(n);
    let bx0 = Infinity, by0 = Infinity, bx1 = -Infinity, by1 = -Infinity;
    for (let i = 0; i < n; i++) { xs[i] = poly[i][0]; ys[i] = poly[i][1]; bx0 = Math.min(bx0, xs[i]); bx1 = Math.max(bx1, xs[i]); by0 = Math.min(by0, ys[i]); by1 = Math.max(by1, ys[i]); }
    const chunks = [];
    for (let s = 0; s < n; s += 24) { // segment j-1..j for j in [s, e)
      const e = Math.min(n, s + 24); let x0 = Infinity, y0 = Infinity, x1 = -Infinity, y1 = -Infinity;
      for (let j = s; j < e; j++) for (const q of [j, (j - 1 + n) % n]) { x0 = Math.min(x0, xs[q]); x1 = Math.max(x1, xs[q]); y0 = Math.min(y0, ys[q]); y1 = Math.max(y1, ys[q]); }
      chunks.push([s, e, x0, y0, x1, y1]);
    }
    return { n, xs, ys, box: [bx0, by0, bx1, by1], chunks };
  });
}
const boxDist = (x, y, b) => Math.hypot(Math.max(b[0] - x, 0, x - b[2]), Math.max(b[1] - y, 0, y - b[3]));
function signedDistance(P, x, y) {
  let best = Infinity, inside = false;
  for (const p of P) {
    const b = p.box, inBox = x >= b[0] && x <= b[2] && y >= b[1] && y <= b[3];
    if (inBox) { // crossing number, chunk by chunk
      for (const c of p.chunks) {
        if (y < c[3] || y > c[5] || x > c[4]) continue;
        for (let i = c[0]; i < c[1]; i++) {
          const j = (i - 1 + p.n) % p.n, ax = p.xs[i], ay = p.ys[i], bx = p.xs[j], by = p.ys[j];
          if ((ay > y) !== (by > y) && x < (bx - ax) * (y - ay) / (by - ay) + ax) inside = !inside;
        }
      }
    }
    if (boxDist(x, y, b) >= best) continue;
    for (const c of p.chunks) {
      if (Math.hypot(Math.max(c[2] - x, 0, x - c[4]), Math.max(c[3] - y, 0, y - c[5])) >= best) continue;
      for (let i = c[0]; i < c[1]; i++) {
        const j = (i - 1 + p.n) % p.n, ax = p.xs[j], ay = p.ys[j], dx = p.xs[i] - ax, dy = p.ys[i] - ay;
        const l2 = dx * dx + dy * dy;
        let t = l2 === 0 ? 0 : ((x - ax) * dx + (y - ay) * dy) / l2; t = t < 0 ? 0 : t > 1 ? 1 : t;
        const d = Math.hypot(x - (ax + t * dx), y - (ay + t * dy));
        if (d < best) best = d;
      }
    }
  }
  return inside ? -best : best;
}
const groupCache = new Map(); // the distance field of each piece of land, kept while it does not move
function groupField(key, polys, cell) {
  const k = cell + "|" + key;
  if (groupCache.has(k)) return groupCache.get(k);
  const nx = Math.floor(W / cell) + 3, ny = Math.floor(H / cell) + 3, P = prepare(polys);
  const d = new Float64Array(nx * ny), inside = new Uint8Array(nx * ny);
  for (let j = 0; j < ny; j++) for (let i = 0; i < nx; i++) {
    const v = signedDistance(P, (i - 1) * cell, (j - 1) * cell);
    d[j * nx + i] = Math.abs(v); inside[j * nx + i] = v < 0 ? 1 : 0;
  }
  const res = { d, inside };
  if (groupCache.size > 60) groupCache.clear();
  groupCache.set(k, res);
  return res;
}
function field(groups, cell) {
  // the signed distance to the nearest coast: the nearest of the pieces of land, negative inside any
  const nx = Math.floor(W / cell) + 3, ny = Math.floor(H / cell) + 3, d = new Float64Array(nx * ny).fill(Infinity), inside = new Uint8Array(nx * ny);
  for (const g of groups) {
    const f = groupField(g.key, g.polys, cell);
    for (let k = 0; k < d.length; k++) { if (f.d[k] < d[k]) d[k] = f.d[k]; inside[k] |= f.inside[k]; }
  }
  for (let j = 0; j < ny; j++) for (let i = 0; i < nx; i++) {
    const k = j * nx + i;
    d[k] = (i === 0 || j === 0 || i === nx - 1 || j === ny - 1) ? 1000 : inside[k] ? -d[k] : d[k];
  }
  return { cell, nx, ny, d };
}
function seaFloor(f) {
  const d = Float64Array.from(f.d);
  for (let j = 0; j < f.ny; j++) for (let i = 0; i < f.nx; i++) {
    const k = j * f.nx + i, v = d[k];
    if (v > 0 && v < 1000) { const x = (i - 1) * f.cell, y = (j - 1) * f.cell; d[k] = v * (0.45 + 1.1 * fbm(x / 110, y / 110, 3)); }
  }
  return { ...f, d };
}
function at(f, p) {
  const gx = Math.min(Math.max(p[0] / f.cell + 1, 0), f.nx - 1 - 1e-6), gy = Math.min(Math.max(p[1] / f.cell + 1, 0), f.ny - 1 - 1e-6);
  const i = Math.floor(gx), j = Math.floor(gy), tx = gx - i, ty = gy - j;
  const a = f.d[j * f.nx + i], b = f.d[j * f.nx + i + 1], c = f.d[(j + 1) * f.nx + i], d = f.d[(j + 1) * f.nx + i + 1];
  return (a * (1 - tx) + b * tx) * (1 - ty) + (c * (1 - tx) + d * tx) * ty;
}
function contours(f, level) {
  const segs = [], key = p => Math.round(p[0] * 10) + "," + Math.round(p[1] * 10);
  const node = (i, j) => f.d[j * f.nx + i], pos = (i, j) => [(i - 1) * f.cell, (j - 1) * f.cell];
  for (let j = 0; j < f.ny - 1; j++) for (let i = 0; i < f.nx - 1; i++) {
    const v = [node(i, j), node(i + 1, j), node(i + 1, j + 1), node(i, j + 1)], ps = [pos(i, j), pos(i + 1, j), pos(i + 1, j + 1), pos(i, j + 1)];
    const cross = [];
    for (let e = 0; e < 4; e++) {
      const a = v[e], b = v[(e + 1) % 4];
      if ((a < level) !== (b < level)) { const t = (level - a) / (b - a), pa = ps[e], pb = ps[(e + 1) % 4]; cross.push([pa[0] + t * (pb[0] - pa[0]), pa[1] + t * (pb[1] - pa[1])]); }
    }
    if (cross.length === 2) segs.push([cross[0], cross[1]]);
    else if (cross.length === 4) { segs.push([cross[0], cross[1]]); segs.push([cross[2], cross[3]]); }
  }
  const ends = new Map();
  segs.forEach((s, k) => { for (const p of s) { const kk = key(p); if (!ends.has(kk)) ends.set(kk, []); ends.get(kk).push(k); } });
  const used = new Uint8Array(segs.length), out = [];
  for (let k = 0; k < segs.length; k++) {
    if (used[k]) continue; used[k] = 1;
    let line = [segs[k][0], segs[k][1]];
    for (let dir = 0; dir < 2; dir++) {
      for (;;) {
        const tip = line[line.length - 1], kt = key(tip);
        const found = (ends.get(kt) || []).find(m => !used[m]);
        if (found == null) break;
        used[found] = 1; const s = segs[found];
        line.push(key(s[0]) === kt ? s[1] : s[0]);
      }
      if (dir === 0) line.reverse();
    }
    out.push(line);
  }
  return out;
}
function smooth(line, every = 3) {
  const r = []; for (let k = 0; k < line.length; k += every) r.push(line[k]);
  if (line.length && (line.length - 1) % every !== 0) r.push(line[line.length - 1]);
  return r;
}
const metres = b => b <= 0 ? 0 : 2 * Math.sqrt(b) + 0.12 * b + 0.006 * b * b;
function level(m) { let lo = 0, hi = 2000; for (let k = 0; k < 50; k++) { const mid = (lo + hi) / 2; if (metres(mid) < m) lo = mid; else hi = mid; } return lo; }
const LEVELS = { 5: level(5), 10: level(10), 20: level(20), 50: level(50), 100: level(100) };

function pointIn(p, poly) {
  let inside = false;
  for (let i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    const a = poly[i], b = poly[j];
    if ((a[1] > p[1]) !== (b[1] > p[1]) && p[0] < (b[0] - a[0]) * (p[1] - a[1]) / (b[1] - a[1]) + a[0]) inside = !inside;
  }
  return inside;
}
function harbour(lands, p, search = 16, reach = 22) {
  // the most sheltered water near p (geometry.harbour): close to the shore, land in most directions
  const P = prepare(lands); let best = -Infinity, res = p;
  for (let y = -search; y <= search; y++) for (let x = -search; x <= search; x++) {
    const q = [p[0] + x, p[1] + y], off = Math.hypot(x, y);
    if (off > search) continue;
    const d = signedDistance(P, q[0], q[1]);
    if (d < 3.5 || d > 7) continue;
    let hits = 0;
    for (let k = 0; k < 24; k++) {
      const a = 2 * Math.PI * k / 24;
      for (let t = 2; t <= reach; t += 1.5) { const r = [q[0] + t * Math.cos(a), q[1] + t * Math.sin(a)]; if (lands.some(pl => pointIn(r, pl))) { hits++; break; } }
    }
    const score = hits - 0.1 * off;
    if (score > best) { best = score; res = q; }
  }
  return [r2(res[0]), r2(res[1])];
}

// --- drawing the chart ----------------------------------------------------------------------------
const $ = id => document.getElementById(id);
const svg = $("chart"), stage = $("stage"), words = $("words");
let G = null, F = null, BED = null;
let mode = "edit", current = 0, selected = null;

function drawDepth(cell) {
  G = geometry();
  F = field(G.groups, cell); BED = seaFloor(F);
  const fill = (f, lev) => contours(f, lev).map(l => svgPath(smooth(l, 2))).join(" ");
  let s = "";
  for (const [m, color] of [[20, "#e6f2fa"], [10, "#c8e2f3"], [5, "#a6cfec"]]) s += `<path d="${fill(BED, LEVELS[m])}" fill="${color}" fill-rule="evenodd"/>`;
  s += `<path d="${fill(F, 1.6)}" fill="#c2d9a8" fill-rule="evenodd"/>`;
  for (const m of [5, 10, 20, 50, 100]) {
    const dash = m >= 50 ? ' stroke-dasharray="5 3"' : "";
    for (const line of contours(BED, LEVELS[m])) {
      if (line.length < 8 * 4 / cell) continue;
      s += `<path d="${svgPath(smooth(line), false)}" fill="none" stroke="${DEPTHLINE}" stroke-width="0.5"${dash}/>`;
      if (line.length > 50 * 4 / cell) { const p = line[Math.floor(line.length / 3)]; s += `<text x="${f1(p[0])}" y="${f1(p[1] + 2.5)}" class="contour-label">${m}</text>`; }
    }
  }
  $("layer-depth").innerHTML = s;
  let l = "";
  for (const poly of G.lands) l += `<path d="${svgPath(poly)}" fill="#f3e3ae" stroke="${INK}" stroke-width="0.8" stroke-linejoin="round"/>`;
  for (const lev of [-8, -16, -26]) for (const line of contours(F, lev)) if (line.length > 6) l += `<path d="${svgPath(smooth(line), false)}" fill="none" stroke="#c4a96c" stroke-width="0.4"/>`;
  for (const g of G.islands) { // the height of each island at its summit
    let best = 0, top = g.slot.center; const r = g.r * 1.2;
    for (let dy = -r; dy <= r; dy += 3) for (let dx = -r; dx <= r; dx += 3) { const q = [g.slot.center[0] + dx, g.slot.center[1] + dy], v = at(F, q); if (v < best) { best = v; top = q; } }
    l += `<circle cx="${f1(top[0])}" cy="${f1(top[1])}" r="1.2" fill="${INK}"/><text x="${f1(top[0] + 3)}" y="${f1(top[1] + 2.5)}" class="spot">${Math.round(g.elevation)}</text>`;
  }
  $("layer-land").innerHTML = l;
  $("sea-mask").innerHTML = G.lands.map(p => `<path d="${svgPath(p)}" fill="black" stroke="black" stroke-width="6"/>`).join("");
}

function rng(seed) {
  let s = Number((BigInt(seed) * 2654435761n + 12345n) & 0xFFFFFFFFn) | 1; s >>>= 0;
  return () => { s = (s ^ (s << 13)) >>> 0; s = (s ^ (s >>> 17)) >>> 0; s = (s ^ (s << 5)) >>> 0; return (s % 100000) / 100000; };
}
function sounding(d, p) {
  const m = Math.floor(d), dec = Math.floor((d - m) * 10);
  return d < 21 ? `<text x="${f1(p[0])}" y="${f1(p[1])}">${m}<tspan dy="2.5" font-size="6.5">${dec}</tspan></text>` : `<text x="${f1(p[0])}" y="${f1(p[1])}">${m}</text>`;
}
function drawSoundings() {
  if (!$("show-soundings").checked) { $("layer-soundings").innerHTML = ""; return; }
  const next = rng(7), keep = [];
  for (const s of S.islands) keep.push([s.label[0] - 110, s.label[1] - 14, s.label[0] + 110, s.label[1] + 6]);
  const rose = [S.compass[0] - 6, S.compass[1] + 16]; keep.push([rose[0] - 50, rose[1] - 50, rose[0] + 50, rose[1] + 50]);
  const tb = S.titleBlock; keep.push([tb[0] - 165, tb[1] - 18, tb[0] + 165, tb[1] + 42]);
  keep.push([W - 260, H - 26, W, H]);
  if ($("show-portolano").checked) { const b = S.portolano.box; keep.push([b[0] - 4, b[1] - 4, b[0] + b[2] + 4, b[1] + b[3] + 4]); }
  const course = routePolyline();
  let s = "";
  for (let y = 24; y < H - 16; y += 38) for (let x = 24; x < W - 16; x += 44) {
    const p = [x + (next() - 0.5) * 20, y + (next() - 0.5) * 18];
    let ok = at(F, p) > 5;
    for (const b of keep) if (p[0] > b[0] && p[0] < b[2] && p[1] > b[1] && p[1] < b[3]) ok = false;
    for (const q of course) if (Math.abs(q[0] - p[0]) < 9 && Math.abs(q[1] - p[1]) < 9) ok = false;
    if (ok) s += sounding(metres(at(BED, p)) + 0.8 * next(), p);
  }
  let placed = 0, tries = 0;
  while (placed < 9 && tries < 600) {
    tries++;
    const p = [60 + next() * (W - 120), 30 + next() * (H - 60)], d = at(F, p);
    if (d > 3 && d < 7 && metres(at(BED, p)) < 5) {
      s += `<g transform="translate(${f1(p[0])},${f1(p[1])})" stroke="${INK}" stroke-width="0.6"><line x1="-3" x2="3"/><line y1="-3" y2="3"/><circle cx="-2" cy="-2" r="0.5" fill="${INK}" stroke="none"/><circle cx="2" cy="-2" r="0.5" fill="${INK}" stroke="none"/><circle cx="-2" cy="2" r="0.5" fill="${INK}" stroke="none"/><circle cx="2" cy="2" r="0.5" fill="${INK}" stroke="none"/></g>`;
      placed++;
    }
  }
  $("layer-soundings").innerHTML = s;
}

function roseSvg(c, r) {
  let s = `<g class="rose" transform="translate(${f1(c[0])},${f1(c[1])})" stroke="${MAGENTA}" fill="none"><circle r="${f1(r)}" stroke-width="0.8"/><circle r="${f1(r - 6)}" stroke-width="0.5"/>`;
  for (let deg = 0; deg <= 355; deg += 5) {
    const a = rad(deg - 90), l = deg % 30 === 0 ? 6 : deg % 10 === 0 ? 4 : 2.5;
    s += `<line x1="${f1(r * Math.cos(a))}" y1="${f1(r * Math.sin(a))}" x2="${f1((r - l) * Math.cos(a))}" y2="${f1((r - l) * Math.sin(a))}" stroke-width="0.5"/>`;
  }
  for (let deg = 0; deg <= 330; deg += 30) { const a = rad(deg - 90); s += `<text x="${f1((r + 6) * Math.cos(a))}" y="${f1((r + 6) * Math.sin(a) + 2.5)}" text-anchor="middle" font-size="6" fill="${MAGENTA}" stroke="none">${deg}</text>`; }
  s += `<g transform="rotate(-3)"><circle r="${f1(r * 0.62)}" stroke-width="0.5"/>`;
  for (let deg = 0; deg <= 350; deg += 10) { const a = rad(deg - 90); s += `<line x1="${f1(r * 0.62 * Math.cos(a))}" y1="${f1(r * 0.62 * Math.sin(a))}" x2="${f1((r * 0.62 - 2.5) * Math.cos(a))}" y2="${f1((r * 0.62 - 2.5) * Math.sin(a))}" stroke-width="0.4"/>`; }
  s += `<path d="M0,${f1(-r * 0.6)} L2.5,-3 L-2.5,-3 Z" fill="${MAGENTA}" stroke="none"/></g>`;
  s += `<path d="M0,${f1(-r + 6)} L3,0 L0,${f1(r - 6)} L-3,0 Z" fill="none" stroke-width="0.5"/><path d="M${f1(-r + 6)},0 L0,3 L${f1(r - 6)},0 L0,-3 Z" fill="none" stroke-width="0.5"/>`;
  s += `<path d="M0,${f1(-r - 1.5)} l-2.5,5 h5 Z" fill="${MAGENTA}" stroke="none"/><text y="${f1(r * 0.3)}" text-anchor="middle" font-size="4.5" fill="${MAGENTA}" stroke="none">VAR 3°W</text></g>`;
  return s;
}
function borderSvg() {
  const band = 5; let s = `<g class="chart-border"><rect x="0.5" y="0.5" width="${W - 1}" height="${H - 1}" fill="none" stroke="${INK}" stroke-width="0.6"/><rect x="${band}" y="${band}" width="${W - 2 * band}" height="${H - 2 * band}" fill="none" stroke="${INK}" stroke-width="0.6"/>`;
  for (let x = band, k = 0; x < W - band; k++) { const x2 = Math.min(x + 24, W - band); if (k % 2 === 0) s += `<rect x="${f1(x)}" y="1" width="${f1(x2 - x)}" height="${band - 1}" fill="${INK}" opacity="0.75"/><rect x="${f1(x)}" y="${H - band}" width="${f1(x2 - x)}" height="${band - 1}" fill="${INK}" opacity="0.75"/>`; if (k % 10 === 0 && k > 0) s += `<text x="${f1(x)}" y="${band + 8}" text-anchor="middle" class="grad">${k}'</text>`; x = x2; }
  for (let y = band, k = 0; y < H - band; k++) { const y2 = Math.min(y + 24, H - band); if (k % 2 === 0) s += `<rect x="1" y="${f1(y)}" width="${band - 1}" height="${f1(y2 - y)}" fill="${INK}" opacity="0.75"/><rect x="${W - band}" y="${f1(y)}" width="${band - 1}" height="${f1(y2 - y)}" fill="${INK}" opacity="0.75"/>`; if (k % 10 === 0 && k > 0) s += `<text x="${W - band - 3}" y="${f1(y + 3)}" text-anchor="end" class="grad">${k}'</text>`; y = y2; }
  return s + "</g>";
}
function anchorSvg(p, cls = "") {
  const d = "M0,-7.5 V9 M-5,-3.5 H5 M-8,3.5 Q-7,9.5 0,10 Q7,9.5 8,3.5 M-9.5,5.5 L-8,3.5 L-6,5.2 M9.5,5.5 L8,3.5 L6,5.2";
  return `<g class="anchor ${cls}" transform="translate(${f1(p[0])},${f1(p[1])}) scale(0.62) translate(0,-1.5)"><circle cx="0" cy="1.5" r="12.5" class="anchor-halo"/><circle cx="0" cy="-9.6" r="2.2" fill="none"/><path d="${d}" fill="none"/></g>`;
}

// the course: dashed ahead, solid where sailed; in the preview the leg just sailed draws itself
function drawCourse(animate = false) {
  const all = routePolyline();
  let s = `<path id="course-ahead" d="${svgPath(all, false)}" fill="none" stroke="${MAGENTA}" stroke-width="1" stroke-dasharray="6 4" opacity="0.6"/>`;
  const upTo = current === 8 ? route().length - 1 : current;
  if (upTo > 0) {
    const before = routePolyline(upTo - 1);
    if (animate && mode === "preview") {
      if (before.length > 1) s += `<path d="${svgPath(before, false)}" fill="none" stroke="${MAGENTA}" stroke-width="1.8"/>`;
      s += `<path class="leg-draw" d="${svgPath(leg(upTo - 1), false)}" fill="none" stroke="${MAGENTA}" stroke-width="1.8"/>`;
    } else s += `<path d="${svgPath(routePolyline(upTo), false)}" fill="none" stroke="${MAGENTA}" stroke-width="1.8"/>`;
  } else if (animate && mode === "preview") {
    s = `<defs><mask id="reveal"><path class="leg-draw slow" d="${svgPath(all, false)}" fill="none" stroke="white" stroke-width="4"/></mask></defs>` +
      `<path d="${svgPath(all, false)}" fill="none" stroke="${MAGENTA}" stroke-width="1" stroke-dasharray="6 4" opacity="0.6" mask="url(#reveal)"/>`;
  }
  $("layer-course").innerHTML = s;
  for (const p of $("layer-course").querySelectorAll(".leg-draw")) {
    const L = p.getTotalLength(); p.style.strokeDasharray = L; p.style.strokeDashoffset = L;
    p.getBoundingClientRect(); p.classList.add("go"); p.style.strokeDashoffset = 0;
  }
  const r = route();
  const a = current >= 1 && current <= 7 ? r[current] : current === 8 ? r[r.length - 1] : r[0];
  $("layer-anchor").innerHTML = anchorSvg(a, animate && mode === "preview" ? "drop" : "");
}

// --- the words, in html over the drawing (chartMap(html = true)) -------------------------------
const pct = (p) => `left:${(100 * p[0] / W).toFixed(2)}%;top:${(100 * p[1] / H).toFixed(2)}%`;
const esc = t => String(t).replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
function state(n) { return n === current ? " current" : (current === 8 || n < current) ? " visited" : ""; }
function drawWords() {
  let s = `<div class="agenda-strip" style="top:${(100 * S.agenda.y / H).toFixed(2)}%"></div>`;
  S.islands.forEach((isl, i) => {
    const n = i + 1;
    s += `<div class="ct cname${state(n)}" data-kind="label" data-i="${i}" style="${pct(isl.label)}">${n} · ${esc(NAMES[i].toUpperCase())}</div>`;
  });
  const sub = current >= 1 && current <= 7 ? `CHART ${current} OF 7 · ${NAMES[current - 1].toUpperCase()}` : current === 8 ? "LANDFALL · BACK ON THE MAINLAND" : "FROM THE MAINLAND TO SEVEN ISLANDS";
  const tb = S.titleBlock;
  s += `<div class="ct title-block" data-kind="title" style="left:${(100 * tb[0] / W).toFixed(2)}%;top:${(100 * (tb[1] - 12) / H).toFixed(2)}%" ${$("show-portolano").checked ? "hidden" : ""}><div class="tb-title">SEAS OF SCIENTIFIC NIM</div><div class="tb-sub${current ? " current" : ""}">${esc(sub)}</div><div class="tb-note">Soundings and heights in metres · each island at its own scale</div></div>`;
  if (G) G.islands.forEach(g => {
    if (!g.slot.note) return;
    let best = -Infinity, c = g.slot.center;
    for (const p of g.poly) { const v = (p[0] - g.slot.center[0]) * -1 + (p[1] - g.slot.center[1]) * 0.5; if (v > best) { best = v; c = p; } }
    s += `<div class="ct chart-note ct-end" style="${pct([c[0] - 5, c[1] + 10])}">${esc(g.slot.note)}</div>`;
  });
  s += `<div class="ct land-name" data-kind="landLabel" style="${pct(S.landLabel)}">THE MAINLAND</div>`;
  s += `<div class="ct note" style="${pct([W / 2, H - 10])}">Coasts © OpenStreetMap contributors (ODbL) · the mainland is Istria</div>`;
  words.innerHTML = s;
  words.classList.toggle("agenda-on", $("show-agenda").checked || mode === "preview");
  drawPortolano();
}
function drawPortolano() {
  const box = S.portolano.box, el = $("portolano");
  el.style.cssText = `left:${(100 * box[0] / W).toFixed(2)}%;top:${(100 * box[1] / H).toFixed(2)}%;width:${(100 * box[2] / W).toFixed(2)}%;height:${(100 * box[3] / H).toFixed(2)}%`;
  el.hidden = !$("show-portolano").checked;
  const head = current >= 1 && current <= 7 ? `CHART ${current} OF 7 · ${NAMES[current - 1].toUpperCase()}` : current === 8 ? "LANDFALL · BACK ON THE MAINLAND" : "FROM THE MAINLAND TO SEVEN ISLANDS";
  el.querySelector(".pt-head").textContent = head;
  el.querySelector(".pt-body").textContent = S.portolano.texts[current] || "";
  $("pt-for").textContent = current >= 1 && current <= 7 ? `island ${current} · ${NAMES[current - 1]}` : current === 8 ? "landfall (8)" : "the whole map (0)";
  if (document.activeElement !== $("pt-text")) $("pt-text").value = S.portolano.texts[current] || "";
}

// --- handles ----------------------------------------------------------------------------------------
function knob(x, y, kind, i, label) {
  return `<g class="knob" data-kind="${kind}" data-i="${i}" transform="translate(${f1(x)},${f1(y)})"><circle r="7"/><text y="3.5" text-anchor="middle">${label}</text></g>`;
}
function drawHandles() {
  const h = $("layer-handles");
  if (mode !== "edit" || !$("show-handles").checked || !G) { h.innerHTML = ""; return; }
  let s = `<path class="hit coast-hit${selected?.kind === "coast" ? " sel" : ""}" data-kind="coast" d="${svgPath(G.coast)}"/>`;
  G.islands.forEach((g, i) => {
    const sel = selected?.kind === "island" && selected.i === i;
    s += `<path class="hit island-hit${sel ? " sel" : ""}" data-kind="island" data-i="${i}" d="${svgPath(g.poly)}"/>`;
    for (const p of g.islets) s += `<path class="hit island-hit${sel ? " sel" : ""}" data-kind="island" data-i="${i}" d="${svgPath(p)}"/>`;
  });
  // the legs: wide invisible lines to add a turning point, and the turning points
  for (let k = 0; k < route().length - 1; k++) {
    const l = leg(k), sel = selected?.kind === "wp" && selected.k === k;
    s += `<path class="hit leg-hit${sel ? " sel" : ""}" data-kind="leg" data-k="${k}" d="${svgPath(l, false)}"/>`;
    (S.legs[k] || []).forEach((p, j) => {
      const on = sel && selected.j === j;
      s += `<rect class="wp${on ? " sel" : ""}" data-kind="wp" data-k="${k}" data-j="${j}" x="${f1(p[0] - 4)}" y="${f1(p[1] - 4)}" width="8" height="8"/>`;
    });
  }
  route().forEach((p, i) => {
    const sel = selected?.kind === "anchor" && selected.i === i;
    s += `<circle class="anchor-hit${sel ? " sel" : ""}" data-kind="anchor" data-i="${i}" cx="${f1(p[0])}" cy="${f1(p[1])}" r="5.5"/>`;
  });
  s += `<circle class="hit rose-hit" data-kind="compass" cx="${f1(S.compass[0] - 6)}" cy="${f1(S.compass[1] + 16)}" r="34"/>`;
  if (selected?.kind === "island") {
    const s0 = S.islands[selected.i], R = s0.size * 0.62;
    const a = rad(s0.rotate - 90);
    s += `<line class="guide" x1="${f1(s0.center[0])}" y1="${f1(s0.center[1])}" x2="${f1(s0.center[0] + R * Math.cos(a))}" y2="${f1(s0.center[1] + R * Math.sin(a))}"/>`;
    s += knob(s0.center[0] + R * Math.cos(a), s0.center[1] + R * Math.sin(a), "island-rot", selected.i, "↻");
    s += knob(s0.center[0] + s0.size * 0.5, s0.center[1] + s0.size * 0.5, "island-size", selected.i, "⤡");
  }
  if (selected?.kind === "coast") {
    const c = S.coast, a = rad(c.angle - 95 - 90), R = 70;
    s += `<circle class="pivot" cx="${f1(c.trieste[0])}" cy="${f1(c.trieste[1])}" r="3"/>`;
    s += `<line class="guide" x1="${f1(c.trieste[0])}" y1="${f1(c.trieste[1])}" x2="${f1(c.trieste[0] + R * Math.cos(a))}" y2="${f1(c.trieste[1] + R * Math.sin(a))}"/>`;
    s += knob(c.trieste[0] + R * Math.cos(a), c.trieste[1] + R * Math.sin(a), "coast-rot", 0, "↻");
  }
  h.innerHTML = s;
}

// --- rendering, cheap and full ------------------------------------------------------------------------
let pending = null;
function renderAll(cell = 4) {
  $("layer-rose").innerHTML = roseSvg([S.compass[0] - 6, S.compass[1] + 16], 34);
  drawDepth(cell); drawSoundings(); drawCourse(); drawWords(); drawHandles(); inspector(); writeJson();
}
function renderLight() { drawSoundings(); drawCourse(); drawWords(); drawHandles(); }
function scheduleGeometry(cell) { // while dragging: at most once a frame; the coast, coarser (it is the slow part)
  if (pending) return;
  pending = requestAnimationFrame(() => { pending = null; drawDepth(cell); renderLight(); });
}

// --- history and storage --------------------------------------------------------------------------------
let past = [], future = [];
function commit() {
  const snap = JSON.stringify(S);
  if (past[past.length - 1] !== snap) { past.push(snap); if (past.length > 200) past.shift(); future = []; }
  try { localStorage.setItem("voyage-map-editor", snap); } catch (e) {}
}
function restore(snap) { S = withDefaults(JSON.parse(snap)); try { localStorage.setItem("voyage-map-editor", snap); } catch (e) {} renderAll(); }
$("undo").onclick = () => { if (past.length > 1) { future.push(past.pop()); restore(past[past.length - 1]); } };
$("redo").onclick = () => { if (future.length) { const s = future.pop(); past.push(s); restore(s); } };
$("reset").onclick = () => { S = withDefaults(DATA.defaults); selected = null; commit(); renderAll(); msg("Back to the deck's map."); };
document.addEventListener("keydown", e => {
  if (e.target.matches("textarea, input")) return;
  if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "z") { e.preventDefault(); (e.shiftKey ? $("redo") : $("undo")).click(); }
  if ((e.key === "Delete" || e.key === "Backspace") && selected?.kind === "wp") { removeWp(selected.k, selected.j); }
  if (mode === "preview" && e.key === "ArrowRight") step(1);
  if (mode === "preview" && e.key === "ArrowLeft") step(-1);
});

// --- json out and in ----------------------------------------------------------------------------------
function exportJson() {
  const o = clone(S);
  o.islands.forEach((isl, i) => { isl.name = NAMES[i]; });
  const flat = v => Array.isArray(v) ? "[" + v.map(flat).join(", ") + "]" : JSON.stringify(v);
  const row = o => "{" + Object.entries(o).map(([k, v]) => JSON.stringify(k) + ": " + flat(v)).join(", ") + "}";
  const lines = [];
  for (const [k, v] of Object.entries(o)) {
    if (k === "islands") lines.push(`  "islands": [\n${v.map(x => "    " + row(x)).join(",\n")}\n  ]`);
    else if (k === "legs") lines.push(`  "legs": [\n${v.map(x => "    " + flat(x)).join(",\n")}\n  ]`);
    else if (k === "portolano") lines.push(`  "portolano": {\n    "box": ${flat(v.box)},\n    "texts": [\n${v.texts.map(t => "      " + JSON.stringify(t)).join(",\n")}\n    ]\n  }`);
    else if (v && typeof v === "object" && !Array.isArray(v)) lines.push(`  ${JSON.stringify(k)}: ${row(v)}`);
    else lines.push(`  ${JSON.stringify(k)}: ${flat(v)}`);
  }
  return "{\n" + lines.join(",\n") + "\n}\n";
}
function writeJson() { if (document.activeElement !== $("json")) $("json").value = exportJson(); }
const msg = t => { $("json-msg").textContent = t; };
$("copy").onclick = async () => {
  const t = exportJson(); $("json").value = t;
  try { await navigator.clipboard.writeText(t); msg("Copied: paste it in the thread."); }
  catch (e) { $("json").select(); msg("Copy is blocked here: the text is selected, copy it with Ctrl+C."); }
};
$("load").onclick = () => {
  try {
    const j = JSON.parse($("json").value);
    if (!j.islands || !j.coast || !j.legs) throw new Error("this is not the json of the map editor");
    S = withDefaults(j); selected = null; commit(); renderAll(); msg("Loaded.");
  } catch (e) { msg("Could not load it: " + e.message); }
};

// --- dragging ----------------------------------------------------------------------------------------
function mapPoint(e) {
  const r = svg.getBoundingClientRect();
  return [(e.clientX - r.left) / r.width * W, (e.clientY - r.top) / r.height * H];
}
const add = (p, d) => [r2(p[0] + d[0]), r2(p[1] + d[1])];
const rot = (p, c, a) => { const x = p[0] - c[0], y = p[1] - c[1]; return [r2(c[0] + x * Math.cos(a) - y * Math.sin(a)), r2(c[1] + x * Math.sin(a) + y * Math.cos(a))]; };
let drag = null;
function startDrag(e, kind, i, k, j) {
  if (mode !== "edit") return;
  e.preventDefault();
  const p0 = mapPoint(e);
  drag = { kind, i, k, j, p0, s0: clone(S), moved: false };
  if (kind === "island" || kind === "island-rot" || kind === "island-size") select({ kind: "island", i });
  else if (kind === "coast" || kind === "coast-rot") select({ kind: "coast" });
  else if (kind === "wp") select({ kind: "wp", k, j });
  else if (kind === "leg") select({ kind: "wp", k, j: -1 });
  else select({ kind, i });
  drag.pointerId = e.pointerId;
}
let lastDown = { t: 0, x: 0, y: 0 };
stage.addEventListener("pointerdown", e => {
  const t = e.target.closest("[data-kind]");
  // a second press within 350 ms is a double click (pointer events stop the browser's dblclick)
  const now = performance.now(), dbl = now - lastDown.t < 350 && Math.hypot(e.clientX - lastDown.x, e.clientY - lastDown.y) < 6;
  lastDown = { t: dbl ? 0 : now, x: e.clientX, y: e.clientY };
  if (dbl && t && mode === "edit") { e.preventDefault(); doubleClick(e, t); return; }
  if (t) startDrag(e, t.dataset.kind, +t.dataset.i || 0, +t.dataset.k || 0, +t.dataset.j || 0);
  else if (e.target.closest(".pt-resize")) startDrag(e, "portolano-size");
  else if (e.target.closest("#portolano")) startDrag(e, "portolano");
  else if (mode === "edit") select(null);
});
stage.addEventListener("pointermove", e => {
  if (!drag) return;
  const p = mapPoint(e), d = [p[0] - drag.p0[0], p[1] - drag.p0[1]], s0 = drag.s0;
  if (!drag.moved && Math.hypot(d[0], d[1]) > 0.5) { drag.moved = true; try { stage.setPointerCapture(drag.pointerId); } catch (err) {} }
  if (!drag.moved) return;
  let geo = false;
  switch (drag.kind) {
    case "island": {
      const a = s0.islands[drag.i], b = S.islands[drag.i];
      b.center = add(a.center, d); b.label = add(a.label, d); b.anchor = add(a.anchor, d); geo = true; break;
    }
    case "island-rot": {
      const a = s0.islands[drag.i], b = S.islands[drag.i], c = a.center;
      const ang = Math.atan2(p[1] - c[1], p[0] - c[0]) - Math.atan2(drag.p0[1] - c[1], drag.p0[0] - c[0]);
      b.rotate = Math.round(a.rotate + ang * 180 / Math.PI); const da = rad(b.rotate - a.rotate);
      b.anchor = rot(a.anchor, c, da); geo = true; break;
    }
    case "island-size": {
      const a = s0.islands[drag.i], b = S.islands[drag.i], c = a.center;
      const f = Math.max(0.2, Math.hypot(p[0] - c[0], p[1] - c[1]) / Math.max(1, Math.hypot(drag.p0[0] - c[0], drag.p0[1] - c[1])));
      b.size = Math.round(a.size * f); const k = b.size / a.size;
      b.anchor = [r2(c[0] + (a.anchor[0] - c[0]) * k), r2(c[1] + (a.anchor[1] - c[1]) * k)]; geo = true; break;
    }
    case "coast":
      S.coast.trieste = add(s0.coast.trieste, d); S.setOut.anchor = add(s0.setOut.anchor, d); S.landfall.anchor = add(s0.landfall.anchor, d);
      S.landLabel = add(s0.landLabel, d); geo = true; break;
    case "coast-rot": {
      const c = s0.coast.trieste;
      const ang = Math.atan2(p[1] - c[1], p[0] - c[0]) - Math.atan2(drag.p0[1] - c[1], drag.p0[0] - c[0]);
      S.coast.angle = Math.round((s0.coast.angle + ang * 180 / Math.PI) * 10) / 10; const da = rad(S.coast.angle - s0.coast.angle);
      S.setOut.anchor = rot(s0.setOut.anchor, c, da); S.landfall.anchor = rot(s0.landfall.anchor, c, da); geo = true; break;
    }
    case "wp": S.legs[drag.k][drag.j] = add(s0.legs[drag.k][drag.j], d); break;
    case "anchor": {
      const n = drag.i, last = S.islands.length + 1;
      if (n === 0) S.setOut.anchor = add(s0.setOut.anchor, d);
      else if (n === last) S.landfall.anchor = add(s0.landfall.anchor, d);
      else S.islands[n - 1].anchor = add(s0.islands[n - 1].anchor, d);
      break;
    }
    case "label": S.islands[drag.i].label = add(s0.islands[drag.i].label, d); break;
    case "title": S.titleBlock = add(s0.titleBlock, d); break;
    case "landLabel": S.landLabel = add(s0.landLabel, d); break;
    case "compass": S.compass = add(s0.compass, d); break;
    case "portolano": { const b = s0.portolano.box; S.portolano.box = [r2(b[0] + d[0]), r2(b[1] + d[1]), b[2], b[3]]; break; }
    case "portolano-size": { const b = s0.portolano.box; S.portolano.box = [b[0], b[1], Math.max(80, r2(b[2] + d[0])), Math.max(40, r2(b[3] + d[1]))]; break; }
    default: return;
  }
  if (geo) scheduleGeometry(drag.kind.startsWith("coast") ? 8 : 4);
  else if (drag.kind === "compass") { $("layer-rose").innerHTML = roseSvg([S.compass[0] - 6, S.compass[1] + 16], 34); renderLight(); }
  else if (drag.kind.startsWith("portolano")) drawPortolano();
  else renderLight();
});
function endDrag() {
  if (!drag) return;
  const geo = ["island", "island-rot", "island-size", "coast", "coast-rot"].includes(drag.kind);
  if (drag.moved) { commit(); if (geo) busy(() => renderAll()); else { renderLight(); inspector(); writeJson(); } }
  drag = null;
}
stage.addEventListener("pointerup", endDrag);
stage.addEventListener("pointercancel", endDrag);
function doubleClick(e, t) {
  if (t.dataset.kind === "wp") removeWp(+t.dataset.k, +t.dataset.j);
  else if (t.dataset.kind === "leg") {
    // a new turning point on the leg, between the two points it falls between
    const k = +t.dataset.k, p = mapPoint(e).map(r2), l = leg(k);
    let best = Infinity, at = 0;
    for (let q = 0; q < l.length - 1; q++) {
      const a = l[q], b = l[q + 1], dx = b[0] - a[0], dy = b[1] - a[1], l2 = dx * dx + dy * dy || 1;
      const u = Math.max(0, Math.min(1, ((p[0] - a[0]) * dx + (p[1] - a[1]) * dy) / l2));
      const dd = Math.hypot(p[0] - a[0] - u * dx, p[1] - a[1] - u * dy);
      if (dd < best) { best = dd; at = q; }
    }
    S.legs[k] = S.legs[k] || []; S.legs[k].splice(at, 0, p);
    selected = { kind: "wp", k, j: at }; commit(); renderLight(); inspector(); writeJson();
  }
}
function removeWp(k, j) { S.legs[k].splice(j, 1); selected = { kind: "wp", k, j: -1 }; commit(); renderLight(); inspector(); writeJson(); }
function busy(f) { $("busy").hidden = false; setTimeout(() => { f(); $("busy").hidden = true; }, 16); }

// --- the inspector ------------------------------------------------------------------------------------
function select(s) { selected = s; drawHandles(); inspector(); }
function numberRow(label, value, step, on) {
  const id = "n" + Math.random().toString(36).slice(2, 8);
  setTimeout(() => { const el = $(id); if (el) el.onchange = () => { on(parseFloat(el.value)); commit(); busy(() => renderAll()); }; });
  return `<label class="row">${label} <input id="${id}" type="number" step="${step}" value="${value}"></label>`;
}
function button(label, on) {
  const id = "b" + Math.random().toString(36).slice(2, 8);
  setTimeout(() => { const el = $(id); if (el) el.onclick = on; });
  return `<button id="${id}">${label}</button>`;
}
function inspector() {
  const T = $("ins-title"), B = $("ins-body");
  if (!selected) { T.textContent = "Nothing selected"; B.innerHTML = `<p class="muted">Click an island, the coast, a turning point, an anchor or a name on the chart.</p>`; return; }
  const s = selected;
  if (s.kind === "island") {
    const isl = S.islands[s.i], g = G?.islands[s.i];
    T.textContent = `Island ${s.i + 1} · ${NAMES[s.i]}`;
    B.innerHTML = `<p class="muted">${esc(isl.real)}${isl.near.length ? " with " + esc(isl.near.join(", ")) : ""}, ${Math.round(ISLES[isl.real].elevation)} m high. Drag it, or its knobs: ↻ turns, ⤡ scales. Its name and anchor move with it.</p>` +
      numberRow("Center x", isl.center[0], 1, v => isl.center[0] = v) + numberRow("Center y", isl.center[1], 1, v => isl.center[1] = v) +
      numberRow("Size (map units)", isl.size, 1, v => isl.size = v) + numberRow("Turned (degrees)", isl.rotate, 1, v => isl.rotate = v) +
      `<div class="btns">` + button("Anchor in sheltered water", () => {
        const near = [g.poly, ...g.islets]; isl.anchor = harbour(near, g.port); commit(); renderLight(); inspector(); writeJson();
      }) + `</div>`;
  } else if (s.kind === "coast") {
    const c = S.coast;
    T.textContent = "The mainland (Istria)";
    B.innerHTML = `<p class="muted">Drag the land to move it, the ↻ knob to turn it around Trieste. The anchors of Portorož and Koper move with it.</p>` +
      numberRow("Scale (units per km)", c.scale, 0.1, v => { const k = v / c.scale; for (const a of [S.setOut, S.landfall]) a.anchor = [r2(c.trieste[0] + (a.anchor[0] - c.trieste[0]) * k), r2(c.trieste[1] + (a.anchor[1] - c.trieste[1]) * k)]; c.scale = v; }) +
      numberRow("Turned (degrees)", c.angle, 0.5, v => c.angle = v) +
      numberRow("Trieste x", c.trieste[0], 1, v => c.trieste[0] = v) + numberRow("Trieste y", c.trieste[1], 1, v => c.trieste[1] = v) +
      `<label class="row">Coast up to <select id="coast-to"><option value="${DATA.muggia}">Muggia (Istria only)</option><option value="${DATA.coast.length - 1}">Monfalcone (the whole gulf)</option></select></label>`;
    setTimeout(() => { const el = $("coast-to"); el.value = String(c.to); el.onchange = () => { c.to = +el.value; c.openEast = c.to === DATA.muggia; commit(); busy(() => renderAll()); }; });
  } else if (s.kind === "wp") {
    const k = s.k, from = k === 0 ? "Portorož" : `island ${k}`, to = k === S.islands.length ? "Koper" : `island ${k + 1}`;
    T.textContent = `Leg ${k + 1}: ${from} to ${to}`;
    B.innerHTML = `<p class="muted">${(S.legs[k] || []).length} turning points. Drag them; double-click the leg to add one, double-click a point (or Delete) to remove it.</p>` +
      (s.j >= 0 ? `<div class="btns">${button("Remove this turning point", () => removeWp(k, s.j))}</div>` : "");
  } else if (s.kind === "anchor") {
    const last = S.islands.length + 1, name = s.i === 0 ? "Portorož, where the voyage sets out" : s.i === last ? "Koper, the landfall" : `the anchor of island ${s.i} · ${NAMES[s.i - 1]}`;
    T.textContent = "Anchor"; B.innerHTML = `<p class="muted">${esc(name)}: the course calls here and the magenta anchor is drawn here.</p><div class="btns">` + button("Back to sheltered water", () => {
      if (s.i === 0 || s.i === last) {
        const port = s.i === 0 ? S.setOut.port : S.landfall.port;
        const p = harbour([G.coast], coastPoint(G.origin, S.coast.angle, S.coast.scale, S.coast.trieste, port));
        (s.i === 0 ? S.setOut : S.landfall).anchor = p;
      } else { const g = G.islands[s.i - 1]; S.islands[s.i - 1].anchor = harbour([g.poly, ...g.islets], g.port); }
      commit(); renderLight(); writeJson();
    }) + `</div>`;
  } else {
    const names = { label: "Name of an island", title: "Title block", landLabel: "Name of the mainland", compass: "Compass rose", portolano: "Portolano box", "portolano-size": "Portolano box" };
    T.textContent = names[s.kind] || s.kind; B.innerHTML = `<p class="muted">Drag it where it reads best.</p>`;
  }
}

// --- the preview of the slides: agenda bar, map, portolano --------------------------------------------
const STEPS = [{ map: true, n: 0 }];
for (let n = 1; n <= 7; n++) STEPS.push({ map: true, n }, { map: false, n });
STEPS.push({ map: true, n: 8 });
let stepAt = 0, playing = null;
$("pv-steps").innerHTML = STEPS.map((s, i) => `<button class="pv-step${s.map ? " map" : ""}" data-s="${i}" title="${s.map ? "Map slide" : "A slide of the island"}">${s.map ? (s.n === 0 ? "Map" : s.n === 8 ? "Land" : "⚓" + s.n) : s.n}</button>`).join("");
$("pv-steps").onclick = e => { const b = e.target.closest("[data-s]"); if (b) { stop(); show(+b.dataset.s); } };
function barPositions() {
  // where each name sits in the agenda bar: measured from a hidden row of the same names
  let m = stage.querySelector(".agenda-measure");
  if (!m) { m = document.createElement("div"); m.className = "agenda-measure"; stage.appendChild(m); }
  m.style.top = (100 * S.agenda.y / H).toFixed(2) + "%";
  m.innerHTML = NAMES.map((n, i) => `<span class="ct cname bar">${i + 1} · ${esc(n.toUpperCase())}</span>`).join("");
  const r = stage.getBoundingClientRect();
  return [...m.children].map(c => { const b = c.getBoundingClientRect(); return [((b.left + b.width / 2) - r.left) / r.width * W, S.agenda.y + 4]; });
}
function show(i) {
  stepAt = Math.max(0, Math.min(STEPS.length - 1, i));
  const s = STEPS[stepAt];
  current = s.n; $("current").value = String(current);
  for (const b of $("pv-steps").children) b.classList.toggle("on", +b.dataset.s === stepAt);
  stage.classList.toggle("on-map", s.map); stage.classList.toggle("on-slide", !s.map);
  drawWords(); drawCourse(s.map);
  const bar = barPositions();
  const labels = words.querySelectorAll(".cname");
  if (!s.map) labels.forEach((el, k) => { el.classList.add("bar"); el.style.left = (100 * bar[k][0] / W).toFixed(2) + "%"; el.style.top = (100 * bar[k][1] / H).toFixed(2) + "%"; });
  else { // the names start in the bar and sail to their places on the chart
    labels.forEach((el, k) => { el.classList.add("bar", "instant"); el.style.left = (100 * bar[k][0] / W).toFixed(2) + "%"; el.style.top = (100 * bar[k][1] / H).toFixed(2) + "%"; });
    words.getBoundingClientRect();
    labels.forEach((el, k) => { el.classList.remove("instant"); setTimeout(() => { el.classList.remove("bar"); el.style.left = (100 * S.islands[k].label[0] / W).toFixed(2) + "%"; el.style.top = (100 * S.islands[k].label[1] / H).toFixed(2) + "%"; }, 120 + 60 * k); });
  }
  const sh = $("slide-heading") || Object.assign(document.createElement("div"), { id: "slide-heading", className: "slide-heading" });
  stage.appendChild(sh);
  sh.innerHTML = s.map ? "" : `<div class="sh-kicker">Island ${s.n}</div><div class="sh-title">${esc(NAMES[s.n - 1])}</div><div class="sh-lines"><span></span><span></span><span></span></div>`;
}
function step(d) { show(stepAt + d); }
$("pv-prev").onclick = () => { stop(); step(-1); };
$("pv-next").onclick = () => { stop(); step(1); };
function stop() { if (playing) { clearInterval(playing); playing = null; $("pv-play").textContent = "Play the voyage"; } }
$("pv-play").onclick = () => {
  if (playing) return stop();
  if (stepAt >= STEPS.length - 1) show(0);
  $("pv-play").textContent = "Pause";
  playing = setInterval(() => { if (stepAt >= STEPS.length - 1) stop(); else step(1); }, 3200);
};

function setMode(m) {
  mode = m; stop();
  $("tab-edit").classList.toggle("on", m === "edit"); $("tab-preview").classList.toggle("on", m === "preview");
  $("tab-edit").setAttribute("aria-selected", m === "edit"); $("tab-preview").setAttribute("aria-selected", m === "preview");
  $("preview-controls").hidden = m !== "preview";
  stage.classList.toggle("previewing", m === "preview"); stage.classList.remove("on-map", "on-slide");
  $("slide-heading")?.remove();
  $("hint").textContent = m === "edit"
    ? "Drag the islands, the coast, the names, the anchors, the turning points, the rose, the title block and the portolano box. Double-click a leg to add a turning point; double-click a turning point to remove it. The depths follow."
    : "The agenda bar sits at the bottom of every slide; on a map slide the names sail to their islands, the leg just sailed draws itself and the portolano opens. Arrow keys step through.";
  drawHandles();
  if (m === "preview") show(stepAt); else { drawWords(); drawCourse(); }
}
$("tab-edit").onclick = () => setMode("edit");
$("tab-preview").onclick = () => setMode("preview");

// --- the panel's controls ------------------------------------------------------------------------------
for (let n = 1; n <= 8; n++) $("current").insertAdjacentHTML("beforeend", `<option value="${n}">${n === 8 ? "8 · back on land" : n + " · " + esc(NAMES[n - 1])}</option>`);
$("current").onchange = () => { current = +$("current").value; if (mode === "preview") { const k = STEPS.findIndex(s => s.map && s.n === current); show(k); } else { drawCourse(); drawWords(); } };
for (const id of ["show-handles", "show-agenda", "show-portolano"]) $(id).onchange = () => { drawSoundings(); drawWords(); drawHandles(); };
$("show-soundings").onchange = () => drawSoundings();
$("pt-text").oninput = () => { S.portolano.texts[current] = $("pt-text").value; drawPortolano(); writeJson(); };
$("pt-text").onchange = () => commit();
$("agenda-y").value = S.agenda.y;
$("agenda-y").oninput = () => { S.agenda.y = +$("agenda-y").value; drawWords(); writeJson(); };
$("agenda-y").onchange = () => commit();

$("layer-border").innerHTML = borderSvg();
commit();
const t0 = performance.now();
renderAll();
console.log("chart drawn in", Math.round(performance.now() - t0), "ms");
setMode("edit");
}
