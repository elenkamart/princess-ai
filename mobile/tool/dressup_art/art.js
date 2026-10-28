/* Princess AI Dress-Up art: Lulu, her closet, the occasion scenes, weather overlays and icons.
 * Every drawing lives in one 240 x 400 character space so clothes layer onto Lulu exactly.
 * Run `node tool/dressup_art/generate.js` to rebuild lib/features/dressup/dressup_art_data.dart. */
'use strict';

const INK = '#2b2147';
const LINE = ' stroke="' + INK + '" stroke-width="3" stroke-linejoin="round" stroke-linecap="round"';

function p(d, fill) { return '<path d="' + d + '" fill="' + fill + '"' + LINE + '/>'; }
function fillOnly(d, fill) { return '<path d="' + d + '" fill="' + fill + '"/>'; }
function c(cx, cy, r, fill, noLine) { return '<circle cx="' + cx + '" cy="' + cy + '" r="' + r + '" fill="' + fill + '"' + (noLine ? '' : LINE) + '/>'; }
function e(cx, cy, rx, ry, fill, noLine) { return '<ellipse cx="' + cx + '" cy="' + cy + '" rx="' + rx + '" ry="' + ry + '" fill="' + fill + '"' + (noLine ? '' : LINE) + '/>'; }
function rect(x, y, w, h, r, fill, noLine) { return '<rect x="' + x + '" y="' + y + '" width="' + w + '" height="' + h + '" rx="' + r + '" fill="' + fill + '"' + (noLine ? '' : LINE) + '/>'; }
function line(d, color, w) { return '<path d="' + d + '" fill="none" stroke="' + color + '" stroke-width="' + w + '" stroke-linecap="round" stroke-linejoin="round"/>'; }
function star(cx, cy, r, fill, noLine) {
  const pts = [];
  for (let i = 0; i < 10; i++) {
    const a = Math.PI / 5 * i - Math.PI / 2, rr = i % 2 ? r * 0.45 : r;
    pts.push((cx + rr * Math.cos(a)).toFixed(1) + ' ' + (cy + rr * Math.sin(a)).toFixed(1));
  }
  return '<path d="M' + pts.join(' L') + ' Z" fill="' + fill + '"' + (noLine ? '' : LINE) + '/>';
}
function dots(list, fill) { return list.map((d) => c(d[0], d[1], d[2] || 3, fill, true)).join(''); }

/* ---------- shared shapes ---------- */
const TEE = 'M88 144 Q92 136 104 136 L136 136 Q148 136 152 144 L151 238 Q120 244 89 238 Z';
const TEE_SL = ['M88 144 L68 152 L69 184 L88 182 Z', 'M152 144 L172 152 L171 184 L152 182 Z'];
const LONG = 'M86 144 Q90 136 104 136 L136 136 Q150 136 154 144 L153 246 Q120 252 87 246 Z';
const LONG_SL = ['M86 144 L66 152 L67 238 L88 238 Z', 'M154 144 L174 152 L173 238 L152 238 Z'];
const PANTS = 'M90 232 L150 232 L149 342 L125 342 L120 268 L115 342 L91 342 Z';
const SHORTS = 'M90 232 L150 232 L151 284 L125 286 L120 266 L115 286 L89 284 Z';
const SWIM = 'M100 138 L106 138 L110 154 L130 154 L134 138 L140 138 Q150 170 148 238 L150 262 Q136 266 124 270 L120 262 L116 270 Q104 266 90 262 L92 238 Q90 170 100 138 Z';
const SNEAKER_L = 'M94 342 L118 342 L119 360 Q119 368 112 368 L90 368 Q84 368 86 360 Z';
const SNEAKER_R = 'M122 342 L146 342 L154 360 Q156 368 148 368 L128 368 Q121 368 121 360 Z';
const FEET = (skin) => e(104, 356, 14, 9, skin) + e(136, 356, 14, 9, skin);

/* ---------- wardrobe ----------
 * slot: top | bottom | dress | coat | shoes | hat | extra
 * fits: occasions the piece suits.
 * tags: weather the piece is made for - rain (keeps you dry), warm (cold and snow), cool (hot days). */
const ITEMS = [
  // Tops
  { id: 'tee', name: 'Star T-shirt', slot: 'top', fits: ['school', 'park', 'playground', 'kitchen'], tags: [], color: '#ff8fb1',
    draw: (o) => p(TEE_SL[0], o.color) + p(TEE_SL[1], o.color) + p(TEE, o.color) + star(120, 188, 16, '#ffc23d') },
  { id: 'polo', name: 'School shirt', slot: 'top', fits: ['school'], tags: [], color: '#7fb4ec',
    draw: (o) => p(TEE_SL[0], o.color) + p(TEE_SL[1], o.color) + p(TEE, o.color) + p('M104 136 L114 156 L120 142 Z', '#ffffff') + p('M136 136 L126 156 L120 142 Z', '#ffffff') + dots([[120, 166, 2.5], [120, 180, 2.5]], INK) },
  { id: 'sparkle', name: 'Sparkly top', slot: 'top', fits: ['party', 'birthday'], tags: [], color: '#c9a7ff',
    draw: (o) => p(TEE, o.color) + c(86, 150, 16, o.color) + c(154, 150, 16, o.color) + dots([[104, 170], [130, 162], [118, 190], [140, 208], [100, 214], [126, 226]], '#ffffff') + star(112, 200, 7, '#ffc23d', true) + star(138, 184, 6, '#ffc23d', true) },
  { id: 'tank', name: 'Tank top', slot: 'top', fits: ['beach', 'park', 'playground'], tags: ['cool'], color: '#ffd166',
    draw: (o) => p('M98 138 L106 138 L108 150 L132 150 L134 138 L142 138 Q152 150 151 238 Q120 244 89 238 Q88 150 98 138 Z', o.color) + line('M90 196 L150 196', '#ff7a59', 6) + line('M90 214 L150 214', '#ff7a59', 6) },
  { id: 'sweater', name: 'Cozy sweater', slot: 'top', fits: ['school', 'snowplay', 'kitchen'], tags: ['warm'], color: '#3fb08a',
    draw: (o) => p(LONG_SL[0], o.color) + p(LONG_SL[1], o.color) + p(LONG, o.color) + line('M68 230 L87 230', '#ffffff', 4) + line('M153 230 L172 230', '#ffffff', 4) + p('M120 200 C108 188 104 176 113 172 C118 170 120 175 120 177 C120 175 122 170 127 172 C136 176 132 188 120 200 Z', '#ff8fb1') },
  { id: 'xmassweater', name: 'Christmas sweater', slot: 'top', fits: ['christmas', 'school', 'snowplay'], tags: ['warm'], color: '#d13667',
    draw: (o) => p(LONG_SL[0], o.color) + p(LONG_SL[1], o.color) + p(LONG, o.color) + line('M90 166 L98 158 L106 166 L114 158 L122 166 L130 158 L138 166 L146 158 L152 164', '#ffffff', 4) + p('M120 180 L136 214 L104 214 Z', '#3cc48f') + rect(116, 214, 8, 8, 1, '#7a4a2a', true) + star(120, 180, 6, '#ffc23d', true) + line('M68 230 L87 230', '#ffffff', 4) + line('M153 230 L172 230', '#ffffff', 4) },
  { id: 'sportsshirt', name: 'Sports shirt', slot: 'top', fits: ['sports', 'park', 'playground'], tags: ['cool'], color: '#3cc48f',
    draw: (o) => p(TEE_SL[0], o.color) + p(TEE_SL[1], o.color) + p(TEE, o.color) + line('M90 196 L150 196', '#ffffff', 8) + p('M110 136 L120 150 L130 136 Z', '#ffffff') },

  // Bottoms
  { id: 'jeans', name: 'Jeans', plural: true, slot: 'bottom', fits: ['school', 'park', 'playground', 'kitchen'], tags: [], color: '#4a6fb5',
    draw: (o) => p(PANTS, o.color) + line('M120 236 L120 266', '#2f4f8c', 3) + line('M96 334 L114 334', '#9cb6e6', 3) + line('M126 334 L144 334', '#9cb6e6', 3) },
  { id: 'shorts', name: 'Shorts', plural: true, slot: 'bottom', fits: ['park', 'beach', 'playground'], tags: ['cool'], color: '#ff7a59',
    draw: (o) => p(SHORTS, o.color) },
  { id: 'tutu', name: 'Tutu skirt', slot: 'bottom', fits: ['party', 'birthday', 'ballet'], tags: [], color: '#ff8fb1',
    draw: (o) => p('M84 232 L156 232 L174 292 L162 286 L152 296 L141 286 L130 296 L120 286 L110 296 L99 286 L88 296 L78 286 L66 292 Z', '#ffd6e3') + p('M88 232 L152 232 L164 274 L152 268 L142 278 L131 268 L120 278 L109 268 L98 278 L88 268 L76 274 Z', o.color) },
  { id: 'leggings', name: 'Leggings', plural: true, slot: 'bottom', fits: ['school', 'park', 'ballet', 'sports', 'playground', 'kitchen'], tags: [], color: '#8a63d2',
    draw: (o) => p('M92 232 L148 232 L146 344 L126 344 L120 270 L114 344 L94 344 Z', o.color) + dots([[104, 260], [136, 260], [104, 300], [136, 300], [104, 330], [136, 330]], '#ece3ff') },
  { id: 'skirt', name: 'Flower skirt', slot: 'bottom', fits: ['park', 'party', 'birthday', 'school', 'kitchen'], tags: ['cool'], color: '#8a63d2',
    draw: (o) => p('M88 232 L152 232 L166 288 Q120 298 74 288 Z', o.color) + [[100, 256], [128, 248], [114, 276], [146, 276], [88, 280]].map((d) => c(d[0], d[1], 5, '#ffd166', true) + c(d[0], d[1], 2, '#ffffff', true)).join('') },
  { id: 'snowpants', name: 'Snow pants', plural: true, slot: 'bottom', fits: ['snowplay'], tags: ['warm'], color: '#3d6b7a',
    draw: (o) => p('M88 230 L152 230 L151 344 L125 344 L120 268 L115 344 L89 344 Z', o.color) + e(104, 300, 8, 11, '#5f93a8', true) + e(136, 300, 8, 11, '#5f93a8', true) },
  { id: 'sportsshorts', name: 'Sports shorts', plural: true, slot: 'bottom', fits: ['sports', 'park', 'playground'], tags: ['cool'], color: '#2a73c0',
    draw: (o) => p(SHORTS, o.color) + line('M93 238 L91 280', '#ffffff', 4) + line('M147 238 L149 280', '#ffffff', 4) },

  // Dresses and costumes (replace top and bottoms)
  { id: 'partydress', name: 'Party dress', slot: 'dress', fits: ['party', 'birthday', 'christmas'], tags: [], color: '#d13667',
    draw: (o) => p('M92 206 L148 206 L176 300 Q120 318 64 300 Z', o.color) + p('M90 142 Q94 136 106 136 L134 136 Q146 136 150 142 L148 212 L92 212 Z', o.color) + c(86, 150, 15, '#ff8fb1') + c(154, 150, 15, '#ff8fb1') + p('M120 210 L102 200 L102 220 Z', '#ffc23d') + p('M120 210 L138 200 L138 220 Z', '#ffc23d') + c(120, 210, 5, '#ffc23d') + dots([[86, 280], [104, 290], [120, 294], [136, 290], [154, 280], [110, 254], [132, 258], [120, 236]], '#ffd6e3') },
  { id: 'bdaydress', name: 'Birthday dress', slot: 'dress', fits: ['birthday', 'party'], tags: [], color: '#ffc23d',
    draw: (o) => p('M80 248 Q120 258 160 248 L172 298 Q120 312 68 298 Z', '#ffe08a') + p('M92 204 L148 204 L162 252 Q120 262 78 252 Z', o.color) + p('M90 142 Q94 136 106 136 L134 136 Q146 136 150 142 L148 206 L92 206 Z', o.color) + c(86, 150, 15, '#ffe08a') + c(154, 150, 15, '#ffe08a') + dots([[104, 170, 3.5], [134, 180, 3.5], [116, 228, 3.5], [96, 278, 3.5], [140, 284, 3.5]], '#d13667') + dots([[124, 160, 3.5], [102, 196, 3.5], [140, 230, 3.5], [118, 290, 3.5]], '#2a73c0') + dots([[140, 160, 3.5], [110, 248, 3.5], [156, 276, 3.5], [82, 284, 3.5]], '#3cc48f') },
  { id: 'sundress', name: 'Sundress', slot: 'dress', fits: ['beach', 'park'], tags: ['cool'], color: '#ffd166',
    draw: (o) => p('M100 138 L106 138 L108 152 L132 152 L134 138 L140 138 Q148 160 146 204 L166 294 Q120 306 74 294 L94 204 Q92 160 100 138 Z', o.color) + [[104, 236], [132, 228], [116, 266], [146, 270], [92, 276], [124, 288]].map((d) => c(d[0], d[1], 6, '#ff8fb1', true) + c(d[0], d[1], 2.5, '#ffffff', true)).join('') },
  { id: 'pajamas', name: 'Pajamas', plural: true, slot: 'dress', fits: ['bedtime', 'sleepover'], tags: [], color: '#9fd3ff',
    draw: (o) => p('M92 232 L148 232 L148 344 L125 344 L120 270 L115 344 L92 344 Z', o.color) + p(LONG_SL[0], o.color) + p(LONG_SL[1], o.color) + p(LONG, o.color) + p('M104 136 L114 152 L120 142 L126 152 L136 136 Z', '#ffffff') + dots([[104, 176], [134, 172], [118, 204], [100, 226], [140, 222], [104, 290], [136, 300], [102, 324], [138, 330], [76, 190], [164, 200]], '#ffffff') },
  { id: 'nightgown', name: 'Nightgown', slot: 'dress', fits: ['bedtime', 'sleepover'], tags: [], color: '#ece3ff',
    draw: (o) => p(LONG_SL[0], o.color) + p(LONG_SL[1], o.color) + p('M88 142 Q92 136 104 136 L136 136 Q148 136 152 142 L162 334 Q120 344 78 334 Z', o.color) + star(104, 200, 7, '#ffc23d', true) + star(136, 240, 6, '#ffc23d', true) + star(112, 290, 7, '#ffc23d', true) + star(142, 306, 5, '#ffc23d', true) + p('M134 168 A10 10 0 1 1 124 156 A8 8 0 0 0 134 168 Z', '#ffc23d') },
  { id: 'swimsuit', name: 'Swimsuit', slot: 'dress', fits: ['beach', 'swimming'], tags: ['cool'], color: '#2a9fd6',
    draw: (o) => p(SWIM, o.color) + line('M93 190 L147 190', '#ffffff', 6) + line('M92 214 L148 214', '#ffffff', 6) },
  { id: 'leotard', name: 'Ballet leotard', slot: 'dress', fits: ['ballet'], tags: [], color: '#ff8fb1',
    draw: (o) => p(SWIM, o.color) + p('M82 226 L158 226 L174 256 L160 250 L148 260 L134 250 L120 260 L106 250 L92 260 L80 250 L66 256 Z', '#ffd6e3') + star(120, 172, 7, '#ffffff', true) },
  { id: 'witchdress', name: 'Witch costume', slot: 'dress', fits: ['halloween'], tags: [], color: '#5b3aa6',
    draw: (o) => p(LONG_SL[0], o.color) + p(LONG_SL[1], o.color) + p('M88 142 Q92 136 104 136 L136 136 Q148 136 152 142 L166 330 L154 322 L144 332 L132 322 L120 332 L108 322 L96 332 L86 322 L74 330 Z', o.color) + line('M90 202 L150 202', '#ffc23d', 6) + star(106, 252, 7, '#ffc23d', true) + star(138, 286, 6, '#ffc23d', true) },
  { id: 'catcostume', name: 'Cat costume', slot: 'dress', fits: ['halloween'], tags: [], color: '#3a3170',
    draw: (o) => line('M150 240 Q190 240 184 196', o.color, 8) + p('M92 232 L148 232 L148 344 L125 344 L120 270 L115 344 L92 344 Z', o.color) + p(LONG_SL[0], o.color) + p(LONG_SL[1], o.color) + p(LONG, o.color) + e(120, 200, 18, 30, '#ece3ff', true) },

  { id: 'overalls', name: 'Play overalls', plural: true, slot: 'dress', fits: ['playground', 'park', 'kitchen'], tags: [], color: '#4a6fb5',
    draw: (o) => p(TEE_SL[0], '#ffd166') + p(TEE_SL[1], '#ffd166') + p(TEE, '#ffd166') + line('M70 168 L87 168', '#ff7a59', 4) + line('M153 168 L170 168', '#ff7a59', 4) + p(PANTS, o.color) + p('M98 172 L142 172 L144 240 L96 240 Z', o.color) + line('M100 174 L104 140', o.color, 6) + line('M140 174 L136 140', o.color, 6) + dots([[101, 180, 3.5], [139, 180, 3.5]], '#ffc23d') + rect(108, 192, 24, 18, 3, '#5b86c9') },

  // Coats
  { id: 'raincoat', name: 'Raincoat', slot: 'coat', fits: [], tags: ['rain'], color: '#ffc23d',
    draw: (o) => p('M84 144 L64 152 L66 240 L88 240 Z', o.color) + p('M156 144 L176 152 L174 240 L152 240 Z', o.color) + p('M84 142 Q88 134 102 134 L138 134 Q152 134 156 142 L164 278 Q120 286 76 278 Z', o.color) + line('M120 142 L120 280', INK, 3) + dots([[128, 170, 3.5], [128, 200, 3.5], [128, 230, 3.5]], INK) + p('M100 134 L114 150 L120 136 L126 150 L140 134 Z', o.color) },
  { id: 'jacket', name: 'Denim jacket', slot: 'coat', fits: ['school', 'park', 'playground'], tags: ['warm'], color: '#5b86c9',
    draw: (o) => p('M84 144 L64 152 L66 238 L88 238 Z', o.color) + p('M156 144 L176 152 L174 238 L152 238 Z', o.color) + p('M84 142 Q88 134 102 134 L112 134 L114 240 L86 240 Z', o.color) + p('M156 142 Q152 134 138 134 L128 134 L126 240 L154 240 Z', o.color) + p('M92 170 L108 170 L108 184 L92 184 Z', '#7fa4dd') + p('M132 170 L148 170 L148 184 L132 184 Z', '#7fa4dd') },
  { id: 'puffer', name: 'Puffer coat', slot: 'coat', fits: ['snowplay'], tags: ['warm'], color: '#2a9fd6',
    draw: (o) => p('M82 146 L62 154 L64 242 L88 242 Z', o.color) + p('M158 146 L178 154 L176 242 L152 242 Z', o.color) + p('M82 142 Q86 132 102 132 L138 132 Q154 132 158 142 L162 272 Q120 280 78 272 Z', o.color) + line('M81 172 L159 172', '#1d78ad', 3) + line('M80 202 L160 202', '#1d78ad', 3) + line('M79 232 L161 232', '#1d78ad', 3) + line('M63 196 L87 196', '#1d78ad', 3) + line('M153 196 L177 196', '#1d78ad', 3) + line('M120 136 L120 276', INK, 3) + p('M98 132 L98 122 L142 122 L142 132 L120 144 Z', o.color) },

  { id: 'apron', name: 'Apron', slot: 'coat', fits: ['kitchen'], tags: [], color: '#ff8fb1',
    draw: (o) => line('M104 152 Q120 126 136 152', o.color, 5) + p('M104 150 L136 150 L138 190 L152 196 L156 290 Q120 300 84 290 L88 196 L102 190 Z', o.color) + line('M88 198 L66 206 M152 198 L174 206', o.color, 5) + dots([[110, 166], [130, 176], [100, 222], [126, 216], [146, 240], [110, 262], [138, 274], [94, 280]], '#ffffff') + rect(106, 232, 28, 22, 4, '#ffd6e3') },

  // Shoes
  { id: 'sneakers', name: 'Sneakers', plural: true, slot: 'shoes', fits: ['school', 'park', 'playground'], tags: [], color: '#ffffff',
    draw: (o) => p(SNEAKER_L, o.color) + p(SNEAKER_R, o.color) + line('M88 362 L117 362', '#d13667', 4) + line('M123 362 L152 362', '#d13667', 4) + line('M100 350 L112 350', '#2a73c0', 3) + line('M128 350 L140 350', '#2a73c0', 3) },
  { id: 'runners', name: 'Running shoes', plural: true, slot: 'shoes', fits: ['sports', 'park', 'school', 'playground'], tags: [], color: '#ffc23d',
    draw: (o) => p(SNEAKER_L, o.color) + p(SNEAKER_R, o.color) + line('M88 362 L117 362', '#ffffff', 4) + line('M123 362 L152 362', '#ffffff', 4) + line('M92 356 Q104 358 114 348', '#d13667', 3) + line('M126 348 Q136 358 148 356', '#d13667', 3) },
  { id: 'boots', name: 'Rain boots', plural: true, slot: 'shoes', fits: [], tags: ['rain'], color: '#d13667',
    draw: (o) => p('M97 316 L119 316 L119 362 Q119 368 112 368 L90 368 Q84 368 86 358 L97 350 Z', o.color) + p('M121 316 L143 316 L143 350 L154 358 Q156 368 148 368 L128 368 Q121 368 121 362 Z', o.color) + line('M98 324 L118 324', '#ffd6e3', 4) + line('M122 324 L142 324', '#ffd6e3', 4) },
  { id: 'snowboots', name: 'Snow boots', plural: true, slot: 'shoes', fits: ['snowplay'], tags: ['warm', 'rain'], color: '#7a4a2a',
    draw: (o) => p('M95 312 L119 312 L119 362 Q119 368 112 368 L88 368 Q82 368 84 358 L95 348 Z', o.color) + p('M121 312 L145 312 L145 348 L156 358 Q158 368 150 368 L128 368 Q121 368 121 362 Z', o.color) + e(107, 314, 15, 7, '#ffffff') + e(133, 314, 15, 7, '#ffffff') },
  { id: 'sandals', name: 'Sandals', plural: true, slot: 'shoes', fits: ['beach'], tags: ['cool'], color: '#ff7a59',
    draw: (o) => FEET(o.skin) + line('M90 352 L118 352', o.color, 6) + line('M122 352 L150 352', o.color, 6) + line('M88 366 L120 366', '#c98a00', 5) + line('M120 366 L152 366', '#c98a00', 5) },
  { id: 'flipflops', name: 'Flip-flops', plural: true, slot: 'shoes', fits: ['beach', 'swimming'], tags: ['cool'], color: '#3cc48f',
    draw: (o) => FEET(o.skin) + line('M88 366 L120 366', o.color, 6) + line('M120 366 L152 366', o.color, 6) + line('M104 350 L94 362 M104 350 L114 362', o.color, 4) + line('M136 350 L126 362 M136 350 L146 362', o.color, 4) },
  { id: 'partyshoes', name: 'Party shoes', plural: true, slot: 'shoes', fits: ['party', 'birthday', 'christmas', 'halloween'], tags: [], color: '#ff8fb1',
    draw: (o) => p('M94 348 L118 348 L119 362 Q119 368 112 368 L90 368 Q84 368 86 362 Z', o.color) + p('M122 348 L146 348 L154 362 Q156 368 148 368 L128 368 Q121 368 121 362 Z', o.color) + line('M96 352 L118 346', INK, 3) + line('M122 346 L144 352', INK, 3) + c(110, 356, 3, '#ffffff', true) + c(134, 356, 3, '#ffffff', true) },
  { id: 'balletshoes', name: 'Ballet shoes', plural: true, slot: 'shoes', fits: ['ballet'], tags: [], color: '#ffb3c8',
    draw: (o) => line('M100 346 L116 322 M116 346 L100 322', '#ff8fb1', 3) + line('M124 346 L140 322 M140 346 L124 322', '#ff8fb1', 3) + p('M96 346 L118 346 L119 362 Q119 368 112 368 L92 368 Q86 368 88 360 Z', o.color) + p('M122 346 L144 346 L152 360 Q154 368 148 368 L128 368 Q121 368 121 362 Z', o.color) },
  { id: 'slippers', name: 'Bunny slippers', plural: true, slot: 'shoes', fits: ['bedtime', 'sleepover', 'kitchen'], tags: [], color: '#ffffff',
    draw: (o) => e(96, 334, 5, 13, o.color) + e(110, 334, 5, 13, o.color) + e(130, 334, 5, 13, o.color) + e(144, 334, 5, 13, o.color) + e(103, 356, 19, 12, o.color) + e(137, 356, 19, 12, o.color) + dots([[97, 352, 2], [109, 352, 2], [131, 352, 2], [143, 352, 2]], INK) + dots([[103, 359, 3], [137, 359, 3]], '#ff8fb1') },

  // Hats
  { id: 'sunhat', name: 'Sun hat', slot: 'hat', fits: ['beach', 'park'], tags: ['cool'], color: '#f2c66d',
    draw: (o) => e(120, 50, 74, 15, o.color) + p('M86 50 Q88 16 120 16 Q152 16 154 50 Z', o.color) + line('M88 42 L152 42', '#ff7a59', 7) },
  { id: 'cap', name: 'Cap', slot: 'hat', fits: ['park', 'sports', 'playground'], tags: ['cool'], color: '#2a73c0',
    draw: (o) => p('M150 56 Q188 54 194 64 Q172 68 150 64 Z', o.color) + p('M76 60 Q78 20 120 20 Q162 20 164 60 Z', o.color) + c(120, 20, 4, '#ffc23d') },
  { id: 'rainhat', name: 'Rain hat', slot: 'hat', fits: [], tags: ['rain'], color: '#ffc23d',
    draw: (o) => p('M66 70 Q76 62 82 50 Q90 18 120 18 Q150 18 158 50 Q164 62 174 70 Q120 82 66 70 Z', o.color) },
  { id: 'beanie', name: 'Beanie', slot: 'hat', fits: ['snowplay'], tags: ['warm'], color: '#d13667',
    draw: (o) => p('M78 66 Q76 22 120 22 Q164 22 162 66 Z', o.color) + rect(74, 56, 92, 16, 6, '#ffd6e3') + c(120, 18, 11, '#ffffff') },
  { id: 'crown', name: 'Crown', slot: 'hat', fits: ['party', 'birthday', 'halloween'], tags: [], color: '#ffc23d',
    draw: (o) => p('M88 48 L92 14 L106 32 L120 6 L134 32 L148 14 L152 48 Z', o.color) + c(120, 36, 5, '#d13667') + c(102, 40, 4, '#2a9fd6') + c(138, 40, 4, '#3cc48f') },
  { id: 'partyhat', name: 'Party hat', slot: 'hat', fits: ['birthday', 'party'], tags: [], color: '#2a73c0',
    draw: (o) => p('M98 50 L120 -6 L142 50 Z', o.color) + line('M107 28 L133 28', '#ffc23d', 4) + line('M102 41 L138 41', '#ffc23d', 4) + c(120, -8, 7, '#d13667') },
  { id: 'witchhat', name: 'Witch hat', slot: 'hat', fits: ['halloween'], tags: [], color: '#3a3170',
    draw: (o) => e(120, 54, 76, 14, o.color) + p('M88 54 L122 -14 Q130 -12 128 -2 L152 54 Z', o.color) + p('M90 44 L150 44 L153 54 L87 54 Z', '#ff7a59') },
  { id: 'catears', name: 'Cat ears', plural: true, slot: 'hat', fits: ['halloween'], tags: [], color: '#3a3170',
    draw: (o) => line('M78 64 Q120 30 162 64', o.color, 7) + p('M84 54 L88 18 L110 38 Z', o.color) + p('M156 54 L152 18 L130 38 Z', o.color) + fillOnly('M90 46 L92 28 L104 38 Z', '#ff8fb1') + fillOnly('M150 46 L148 28 L136 38 Z', '#ff8fb1') },
  { id: 'santahat', name: 'Santa hat', slot: 'hat', fits: ['christmas'], tags: ['warm'], color: '#d13667',
    draw: (o) => p('M80 58 Q92 10 132 12 Q170 18 182 66 L168 66 Q160 40 148 40 L160 58 Z', o.color) + p('M74 52 L166 52 Q170 60 166 68 L74 68 Q70 60 74 52 Z', '#ffffff') + c(176, 70, 9, '#ffffff') },
  { id: 'swimcap', name: 'Swim cap', slot: 'hat', fits: ['swimming'], tags: [], color: '#ff7a59',
    draw: (o) => p('M72 82 Q70 30 120 30 Q170 30 168 82 Q120 70 72 82 Z', o.color) + dots([[100, 50, 4], [126, 44, 4], [146, 60, 4], [110, 66, 4]], '#ffd6e3') },

  { id: 'chefhat', name: 'Chef hat', slot: 'hat', fits: ['kitchen'], tags: [], color: '#ffffff',
    draw: (o) => c(96, 22, 18, o.color) + c(144, 22, 18, o.color) + c(120, 12, 22, o.color) + rect(86, 26, 68, 28, 6, o.color) },
  { id: 'sleepmask', name: 'Sleep mask', slot: 'hat', fits: ['sleepover', 'bedtime'], tags: [], color: '#c9a7ff',
    draw: (o) => line('M74 62 Q120 50 166 62', o.color, 5) + p('M90 54 Q104 44 118 54 Q120 56 122 54 Q136 44 150 54 Q152 70 136 72 Q124 72 120 66 Q116 72 104 72 Q88 70 90 54 Z', o.color) + star(104, 60, 5, '#ffc23d', true) + star(136, 60, 5, '#ffc23d', true) },

  // Extras
  { id: 'backpack', name: 'Backpack', slot: 'extra', fits: ['school'], tags: [], color: '#3fb08a',
    back: (o) => rect(146, 148, 38, 88, 12, o.color),
    draw: (o) => line('M100 138 L102 214', o.color, 8) + line('M140 138 L138 214', o.color, 8) },
  { id: 'sunglasses', name: 'Sunglasses', plural: true, slot: 'extra', fits: ['beach'], tags: ['cool'], color: '#2b2147',
    draw: (o) => rect(88, 82, 26, 18, 7, o.color) + rect(126, 82, 26, 18, 7, o.color) + line('M114 88 L126 88', INK, 3) + line('M92 86 L98 86', '#ffffff', 3) + line('M130 86 L136 86', '#ffffff', 3) },
  { id: 'waterbottle', name: 'Water bottle', slot: 'extra', fits: ['sports', 'park', 'beach', 'playground'], tags: ['cool'], color: '#2a9fd6',
    draw: (o) => rect(66, 210, 14, 10, 3, '#ffffff') + rect(62, 218, 22, 46, 7, o.color) + line('M64 238 L82 238', '#9fd3ff', 4) },
  { id: 'umbrella', name: 'Umbrella', slot: 'extra', fits: [], tags: ['rain'], color: '#2a73c0',
    draw: (o) => line('M168 34 L168 244 Q168 256 158 256', '#7a4a2a', 5) + p('M96 40 Q168 -24 240 40 Q222 30 204 40 Q186 30 168 40 Q150 30 132 40 Q114 30 96 40 Z', o.color) + line('M168 -6 L168 4', INK, 4) },
  { id: 'scarfmittens', name: 'Scarf and mittens', plural: true, slot: 'extra', fits: ['snowplay'], tags: ['warm'], color: '#ff7a59',
    draw: (o) => p('M124 146 L134 196 L120 198 L114 150 Z', o.color) + p('M98 128 Q120 142 142 128 L146 144 Q120 160 94 144 Z', o.color) + line('M100 138 Q120 150 140 138', '#ffffff', 3) + e(70, 244, 5, 7, o.color) + e(170, 244, 5, 7, o.color) + e(78.5, 252, 12, 14, o.color) + e(161.5, 252, 12, 14, o.color) },
  { id: 'goggles', name: 'Swim goggles', plural: true, slot: 'extra', fits: ['swimming'], tags: [], color: '#2a9fd6',
    draw: (o) => line('M72 90 L168 90', o.color, 5) + e(102, 90, 13, 10, '#9fd3ff') + e(138, 90, 13, 10, '#9fd3ff') + line('M115 90 L125 90', INK, 3) + line('M96 86 L102 84', '#ffffff', 3) + line('M132 86 L138 84', '#ffffff', 3) },
  { id: 'present', name: 'Present', slot: 'extra', fits: ['birthday', 'christmas'], tags: [], color: '#d13667',
    draw: (o) => rect(50, 228, 42, 36, 4, o.color) + line('M71 228 L71 264', '#ffc23d', 6) + line('M50 245 L92 245', '#ffc23d', 6) + p('M71 228 Q58 214 64 211 Q71 209 71 228 Z', '#ffc23d') + p('M71 228 Q84 214 78 211 Q71 209 71 228 Z', '#ffc23d') },
  { id: 'pumpkin', name: 'Pumpkin bucket', slot: 'extra', fits: ['halloween'], tags: [], color: '#ff7a59',
    draw: (o) => line('M56 240 Q71 212 86 240', INK, 3) + e(71, 250, 19, 16, o.color) + e(71, 250, 7, 16, 'none') + fillOnly('M62 246 L66 240 L70 246 Z', INK) + fillOnly('M72 246 L76 240 L80 246 Z', INK) + fillOnly('M62 254 Q71 262 80 254 L76 258 L71 256 L66 258 Z', INK) },
  { id: 'teddy', name: 'Teddy bear', slot: 'extra', fits: ['bedtime', 'sleepover'], tags: [], color: '#b07a4f',
    draw: (o) => c(70, 254, 16, o.color) + c(60, 214, 5, o.color) + c(80, 214, 5, o.color) + c(70, 226, 13, o.color) + e(70, 231, 6, 4.5, '#e3c0a0', true) + dots([[65, 223, 1.8], [75, 223, 1.8], [70, 230, 1.8]], INK) + e(70, 258, 8, 9, '#e3c0a0', true) },
  { id: 'ovenmitt', name: 'Oven mitt', slot: 'extra', fits: ['kitchen'], tags: [], color: '#d13667',
    draw: (o) => e(62, 238, 6, 10, o.color) + p('M66 262 L66 228 Q66 210 79 210 Q92 210 92 228 L92 262 Z', o.color) + line('M66 252 L92 252', '#ffffff', 4) },
  { id: 'sleepingbag', name: 'Sleeping bag', slot: 'extra', fits: ['sleepover'], tags: [], color: '#3fb08a',
    draw: (o) => rect(36, 234, 50, 30, 15, o.color) + c(42, 249, 13, '#9fd3ff') + c(42, 249, 5, o.color) + line('M58 236 L58 262', '#2b8a6a', 3) }
];

const THUMBS = {
  top: '56 126 128 130', bottom: '60 222 120 130', dress: '52 128 136 196', coat: '54 124 132 170',
  shoes: '78 308 84 66', hat: '56 0 144 90',
  pajamas: '52 128 136 222', nightgown: '52 128 136 222', catcostume: '52 128 140 222', witchdress: '52 128 136 210',
  partyhat: '56 -18 144 108', witchhat: '36 -20 168 92', santahat: '60 0 140 90', swimcap: '56 20 128 70',
  backpack: '90 126 100 120', sunglasses: '82 72 76 36', goggles: '66 74 108 32', umbrella: '90 -22 152 284',
  teddy: '48 200 44 74', waterbottle: '50 204 46 66', present: '40 204 64 66', pumpkin: '44 206 56 66',
  scarfmittens: '58 120 124 150', overalls: '52 128 136 222', apron: '54 120 132 184', chefhat: '70 -14 100 72',
  sleepmask: '68 40 104 40', ovenmitt: '50 204 48 64', sleepingbag: '24 228 70 42'
};

const SLOTS = [
  ['top', 'Tops'], ['bottom', 'Bottoms'], ['dress', 'Dresses'], ['coat', 'Coats'],
  ['shoes', 'Shoes'], ['hat', 'Hats'], ['extra', 'Extras']
];

/* outdoor: the weather matters for this occasion. */
const OCCASIONS = {
  school: { name: 'School', outdoor: true, hello: 'Time for school! What should I wear?', yay: 'Ready to learn! Thank you!' },
  park: { name: 'Park', outdoor: true, hello: 'Let’s go play in the park!', yay: 'Let’s play outside!' },
  playground: { name: 'Playground', outdoor: true, hello: 'To the playground! I want to climb and slide.', yay: 'Wheee! Down the slide!' },
  kitchen: { name: 'Kitchen', outdoor: false, hello: 'Let’s bake cookies! What should I wear?', yay: 'Yum! I’m ready to cook!' },
  sleepover: { name: 'Sleepover', outdoor: false, hello: 'Sleepover at my friend’s house! What should I bring?', yay: 'Pillow fight! Best night ever!' },
  beach: { name: 'Beach', outdoor: true, hello: 'We’re going to the beach!', yay: 'Sun, sand and sea!' },
  sports: { name: 'Sports', outdoor: true, hello: 'Time for sports! I want to run fast.', yay: 'Ready, set, go!' },
  snowplay: { name: 'Snow day', outdoor: true, hello: 'Snow! Let’s go build a snowman.', yay: 'Snowball time! I’m nice and warm.' },
  swimming: { name: 'Swimming', outdoor: false, hello: 'Swimming lesson today! Splash!', yay: 'Into the pool I go!' },
  ballet: { name: 'Ballet', outdoor: false, hello: 'Ballet class! I want to twirl.', yay: 'Twirl, twirl, twirl!' },
  party: { name: 'Party', outdoor: false, hello: 'It’s party time! Make me sparkle.', yay: 'Party time! I feel sparkly!' },
  birthday: { name: 'Birthday', outdoor: false, hello: 'It’s a birthday! Let’s look special.', yay: 'Happy birthday! Let’s eat cake!' },
  halloween: { name: 'Halloween', outdoor: false, hello: 'Trick or treat! What will I be?', yay: 'Boo! What a great costume!' },
  christmas: { name: 'Christmas', outdoor: false, hello: 'It’s Christmas! Let’s look cozy and bright.', yay: 'Merry Christmas!' },
  bedtime: { name: 'Bedtime', outdoor: false, hello: 'I’m sleepy. Time for bed!', yay: 'Night night! So cozy.' }
};

const LOOKS = {
  skin: ['#ffdcc6', '#f1b98f', '#d08b5b', '#a0623a', '#6b3f24'],
  hair: ['#3b2a20', '#7a4a2a', '#e0a64a', '#b8452f', '#1f1a1a'],
  style: ['puffs', 'long', 'short']
};

/* ---------- the body, split where clothes layer in ---------- */
function hairBack(style, col) {
  if (style === 'long') return p('M70 90 Q66 36 120 36 Q174 36 170 90 L176 176 Q148 186 120 182 Q92 186 64 176 Z', col);
  if (style === 'puffs') return c(70, 60, 24, col) + c(170, 60, 24, col);
  return p('M72 96 Q68 38 120 38 Q172 38 168 96 L170 112 L70 112 Z', col);
}
function face(mood) {
  const eyes = e(102, 92, 6, 8, INK, true) + e(138, 92, 6, 8, INK, true) + c(104, 89, 2.2, '#ffffff', true) + c(140, 89, 2.2, '#ffffff', true);
  const cheeks = c(92, 108, 7, '#ff8fa8', true).replace('/>', ' opacity=".45"/>') + c(148, 108, 7, '#ff8fa8', true).replace('/>', ' opacity=".45"/>');
  const mouth = mood === 'oops' ? e(120, 116, 5, 6, INK, true)
    : mood === 'happy' ? p('M106 108 Q120 128 134 108 Z', '#ffffff')
      : line('M110 113 Q120 120 130 113', INK, 4);
  return eyes + cheeks + mouth;
}
function parts(skin, hair, style, mood) {
  return {
    hairBack: hairBack(style, hair),
    bodyLower: rect(70, 150, 17, 96, 8.5, skin) + rect(153, 150, 17, 96, 8.5, skin) + rect(99, 240, 18, 112, 9, skin) + rect(123, 240, 18, 112, 9, skin) +
      FEET(skin) + p('M90 150 Q90 140 100 140 L140 140 Q150 140 150 150 L150 250 L90 250 Z', skin),
    undershirt: p('M98 140 L106 140 L108 150 L132 150 L134 140 L142 140 L148 236 L92 236 Z', '#ffffff'),
    undershorts: p('M92 230 L148 230 L148 262 L124 264 L120 254 L116 264 L92 262 Z', '#cfe3ff'),
    bodyUpper: c(78.5, 248, 10, skin) + c(161.5, 248, 10, skin) + rect(111, 124, 18, 22, 6, skin) + c(74, 94, 9, skin) + c(166, 94, 9, skin) + c(120, 88, 46, skin),
    face: face(mood),
    hairFront: p('M72 90 Q72 40 120 40 Q168 40 168 90 Q156 66 132 62 Q126 74 112 70 Q92 66 72 90 Z', hair)
  };
}

/* ---------- scenes (400 x 440) ---------- */
const S = (a) => a.join('');
function bunting(y) {
  const cols = ['#d13667', '#ffc23d', '#2a73c0', '#3cc48f', '#8a63d2'];
  let g = '<path d="M0 ' + y + ' Q200 ' + (y + 44) + ' 400 ' + y + '" fill="none" stroke="#2b2147" stroke-width="3"/>';
  for (let j = 0; j < 9; j++) {
    const bx = 12 + j * 44, by = y + Math.sin((j + .5) / 9 * Math.PI) * 30;
    g += '<path d="M' + bx + ' ' + by.toFixed(1) + ' l24 0 l-12 26 z" fill="' + cols[j % 5] + '" stroke="#2b2147" stroke-width="3" stroke-linejoin="round"/>';
  }
  return g;
}
function nightStars(list) { return list.map((s) => '<circle cx="' + s[0] + '" cy="' + s[1] + '" r="3" fill="#ffffff"/>').join(''); }

const BACKDROPS = {
  school: S(['<rect width="400" height="440" fill="#dcecff"/>', '<rect x="30" y="40" width="150" height="96" rx="10" fill="#2f5d50" stroke="#2b2147" stroke-width="4"/>',
    '<text x="105" y="102" text-anchor="middle" font-family="sans-serif" font-weight="800" font-size="34" fill="#ffffff">A B C</text>',
    '<rect x="276" y="56" width="90" height="70" rx="8" fill="#ffffff" stroke="#2b2147" stroke-width="4"/>', '<path d="M276 80 H366 M321 56 V126" stroke="#9cc4ee" stroke-width="4"/>',
    '<rect y="384" width="400" height="56" fill="#f3d9b1"/>']),
  park: S(['<rect width="400" height="440" fill="#dff3ff"/>', '<circle cx="330" cy="70" r="34" fill="#ffc23d"/>', '<ellipse cx="80" cy="420" rx="220" ry="90" fill="#a8e0b9"/>',
    '<ellipse cx="340" cy="430" rx="200" ry="80" fill="#7fcf9a"/>', '<rect x="40" y="250" width="16" height="80" rx="6" fill="#9b6a3a"/>', '<circle cx="48" cy="236" r="44" fill="#3cc48f"/>',
    '<circle cx="352" cy="300" r="10" fill="#ff8fb1"/>', '<circle cx="372" cy="318" r="8" fill="#ffc23d"/>']),
  playground: S(['<rect width="400" height="440" fill="#dff3ff"/>', '<rect y="372" width="400" height="68" fill="#ffe3a3"/>',
    '<path d="M300 380 V180 M340 380 V180" stroke="#d13667" stroke-width="8" stroke-linecap="round"/>', '<path d="M300 200 H340 M300 240 H340 M300 280 H340 M300 320 H340" stroke="#d13667" stroke-width="5"/>',
    '<path d="M340 180 H360 L398 380" fill="none" stroke="#2b2147" stroke-width="3"/>', '<path d="M344 186 L360 186 L396 372 L382 372 Z" fill="#ffc23d" stroke="#2b2147" stroke-width="3" stroke-linejoin="round"/>',
    '<path d="M10 120 H120 M20 120 L4 380 M110 120 L126 380" stroke="#2a73c0" stroke-width="8" stroke-linecap="round"/>', '<path d="M50 122 V300 M80 122 V300" stroke="#2b2147" stroke-width="3"/>',
    '<rect x="42" y="298" width="46" height="10" rx="4" fill="#3cc48f" stroke="#2b2147" stroke-width="3"/>']),
  kitchen: S(['<rect width="400" height="440" fill="#fff1c7"/>', '<path d="M0 60 H400 M0 120 H400 M0 180 H400 M0 240 H400 M100 0 V280 M200 0 V280 M300 0 V280" stroke="#f3e2b0" stroke-width="3"/>',
    '<rect x="16" y="40" width="110" height="80" rx="8" fill="#9fd3ff" stroke="#2b2147" stroke-width="4"/>', '<path d="M16 80 H126 M71 40 V120" stroke="#ffffff" stroke-width="4"/>',
    '<rect y="280" width="400" height="104" fill="#ffffff" stroke="#2b2147" stroke-width="3"/>', '<rect y="268" width="400" height="16" fill="#e2c3ab" stroke="#2b2147" stroke-width="3"/>',
    '<rect x="290" y="296" width="92" height="76" rx="6" fill="#5f5677" stroke="#2b2147" stroke-width="3"/>', '<rect x="302" y="314" width="68" height="44" rx="4" fill="#ffc23d" opacity=".6"/>',
    '<rect x="20" y="300" width="80" height="70" rx="6" fill="#ffd6e3" stroke="#2b2147" stroke-width="3"/>', '<rect y="384" width="400" height="56" fill="#f3d9b1"/>',
    '<ellipse cx="340" cy="250" rx="30" ry="10" fill="#e2c3ab" stroke="#2b2147" stroke-width="3"/>', '<circle cx="330" cy="246" r="7" fill="#b07a4f"/>', '<circle cx="350" cy="244" r="7" fill="#b07a4f"/>',
    '<path d="M300 30 V90 M290 90 h20 l-4 30 h-12 z" fill="#ff8fb1" stroke="#2b2147" stroke-width="3"/>']),
  sleepover: S(['<rect width="400" height="440" fill="#4b3f8a"/>', '<path d="M0 30 Q100 70 200 30 Q300 70 400 30" fill="none" stroke="#ece3ff" stroke-width="2"/>',
    [[30, 44], [80, 54], [130, 46], [180, 34], [230, 46], [280, 54], [330, 46], [380, 36]].map((d, i) => '<circle cx="' + d[0] + '" cy="' + d[1] + '" r="6" fill="' + ['#ffc23d', '#ff8fb1', '#9fd3ff', '#3cc48f'][i % 4] + '"/>').join(''),
    '<path d="M260 384 L330 230 L400 384 Z" fill="#ff8fb1" stroke="#2b2147" stroke-width="3" stroke-linejoin="round"/>', '<path d="M330 230 L312 384 M330 230 L348 384" stroke="#2b2147" stroke-width="3"/>',
    '<path d="M312 384 L330 300 L348 384 Z" fill="#3a3170"/>', '<rect y="384" width="400" height="56" fill="#6b5aa8"/>',
    '<rect x="10" y="356" width="120" height="34" rx="16" fill="#3fb08a" stroke="#2b2147" stroke-width="3"/>', '<ellipse cx="34" cy="364" rx="20" ry="12" fill="#ffffff" stroke="#2b2147" stroke-width="3"/>',
    '<path d="M40 120 A26 26 0 1 1 20 96 A20 20 0 0 0 40 120 Z" fill="#ffc23d"/>']),
  beach: S(['<rect width="400" height="440" fill="#cdeeff"/>', '<circle cx="70" cy="70" r="36" fill="#ffc23d"/>', '<rect y="270" width="400" height="70" fill="#5cc0e8"/>',
    '<path d="M0 286 q25 -12 50 0 t50 0 t50 0 t50 0 t50 0 t50 0 t50 0 t50 0" fill="none" stroke="#ffffff" stroke-width="4"/>', '<rect y="336" width="400" height="104" fill="#ffe3a3"/>',
    '<circle cx="350" cy="380" r="8" fill="#ff7a59"/>']),
  sports: S(['<rect width="400" height="440" fill="#dff3ff"/>', '<rect y="300" width="400" height="140" fill="#7fcf9a"/>', '<path d="M0 360 H400 M200 300 V440" stroke="#ffffff" stroke-width="4"/>',
    '<ellipse cx="200" cy="360" rx="50" ry="18" fill="none" stroke="#ffffff" stroke-width="4"/>', '<path d="M330 300 V220 H396 V300" fill="none" stroke="#ffffff" stroke-width="6"/>',
    '<path d="M330 220 L396 300 M396 220 L330 300" stroke="#ffffff" stroke-width="1.5" opacity=".7"/>', '<circle cx="54" cy="392" r="16" fill="#ffffff" stroke="#2b2147" stroke-width="3"/>',
    '<path d="M54 380 L62 388 L58 398 L50 398 L46 388 Z" fill="#2b2147"/>']),
  snowplay: S(['<rect width="400" height="440" fill="#e6f0f7"/>', '<ellipse cx="90" cy="430" rx="240" ry="100" fill="#ffffff"/>', '<ellipse cx="350" cy="440" rx="200" ry="90" fill="#f4f8fb"/>',
    '<path d="M330 300 L360 220 L390 300 Z M338 260 L360 196 L382 260 Z" fill="#3fb08a" stroke="#2b2147" stroke-width="3" stroke-linejoin="round"/>',
    '<circle cx="56" cy="350" r="28" fill="#ffffff" stroke="#2b2147" stroke-width="3"/>', '<circle cx="56" cy="306" r="20" fill="#ffffff" stroke="#2b2147" stroke-width="3"/>',
    '<path d="M56 308 L76 312 L56 314 Z" fill="#ff7a59"/>', '<circle cx="50" cy="300" r="2.5" fill="#2b2147"/>', '<circle cx="62" cy="300" r="2.5" fill="#2b2147"/>']),
  swimming: S(['<rect width="400" height="440" fill="#dcf3fb"/>', '<path d="M0 60 H400 M0 120 H400 M0 180 H400 M0 240 H400 M80 0 V320 M160 0 V320 M240 0 V320 M320 0 V320" stroke="#b9e3f2" stroke-width="3"/>',
    '<rect y="320" width="400" height="120" fill="#5cc0e8"/>', '<path d="M0 334 q25 -10 50 0 t50 0 t50 0 t50 0 t50 0 t50 0 t50 0 t50 0" fill="none" stroke="#ffffff" stroke-width="4"/>',
    '<path d="M0 392 H400" stroke="#ffc23d" stroke-width="6" stroke-dasharray="10 10"/>', '<path d="M360 250 V340 M384 250 V340 M360 274 H384 M360 300 H384" stroke="#9aa7b4" stroke-width="6" fill="none"/>']),
  ballet: S(['<rect width="400" height="440" fill="#ffe9f0"/>', '<rect x="20" y="40" width="160" height="210" rx="8" fill="#f5fbff" stroke="#2b2147" stroke-width="4"/>',
    '<rect x="220" y="40" width="160" height="210" rx="8" fill="#f5fbff" stroke="#2b2147" stroke-width="4"/>', '<path d="M0 250 H400" stroke="#b07a4f" stroke-width="10" stroke-linecap="round"/>',
    '<path d="M60 250 V384 M340 250 V384" stroke="#b07a4f" stroke-width="6"/>', '<rect y="384" width="400" height="56" fill="#f3d9b1"/>']),
  party: S(['<rect width="400" height="440" fill="#ffe0ea"/>', bunting(26),
    '<ellipse cx="44" cy="190" rx="26" ry="32" fill="#2a73c0" stroke="#2b2147" stroke-width="3"/>', '<path d="M44 222 q-8 30 4 60" fill="none" stroke="#2b2147" stroke-width="3"/>',
    '<ellipse cx="356" cy="170" rx="26" ry="32" fill="#ffc23d" stroke="#2b2147" stroke-width="3"/>', '<path d="M356 202 q8 30 -4 60" fill="none" stroke="#2b2147" stroke-width="3"/>',
    '<rect y="390" width="400" height="50" fill="#ffc6d7"/>']),
  birthday: S(['<rect width="400" height="440" fill="#fff1c7"/>', bunting(26), '<rect y="390" width="400" height="50" fill="#ffd98a"/>',
    '<rect x="300" y="330" width="96" height="60" fill="#ffffff" stroke="#2b2147" stroke-width="3"/>', '<rect x="314" y="290" width="68" height="40" rx="6" fill="#ff8fb1" stroke="#2b2147" stroke-width="3"/>',
    '<rect x="326" y="262" width="44" height="28" rx="6" fill="#ffffff" stroke="#2b2147" stroke-width="3"/>', '<path d="M338 262 V248 M348 262 V248 M358 262 V248" stroke="#2a73c0" stroke-width="4"/>',
    '<path d="M338 244 q-3 -6 0 -10 q3 4 0 10 M348 244 q-3 -6 0 -10 q3 4 0 10 M358 244 q-3 -6 0 -10 q3 4 0 10" fill="#ffc23d" stroke="#ff7a59" stroke-width="2"/>',
    '<ellipse cx="44" cy="190" rx="26" ry="32" fill="#d13667" stroke="#2b2147" stroke-width="3"/>', '<path d="M44 222 q-8 30 4 60" fill="none" stroke="#2b2147" stroke-width="3"/>']),
  halloween: S(['<rect width="400" height="440" fill="#3a2f5c"/>', '<circle cx="320" cy="70" r="36" fill="#ffe08a"/>', nightStars([[40, 50], [110, 30], [200, 70], [60, 140], [380, 160]]),
    '<path d="M70 100 q10 -12 20 0 q10 -12 20 0 q-10 4 -20 14 q-10 -10 -20 -14 z M250 140 q8 -10 16 0 q8 -10 16 0 q-8 3 -16 11 q-8 -8 -16 -11 z" fill="#1f1a1a"/>',
    '<rect y="388" width="400" height="52" fill="#4b3f8a"/>', '<ellipse cx="50" cy="380" rx="30" ry="24" fill="#ff7a59" stroke="#2b2147" stroke-width="3"/>',
    '<path d="M50 356 v-10" stroke="#3fb08a" stroke-width="5"/>', '<path d="M38 374 l6 -8 l6 8 z M54 374 l6 -8 l6 8 z M36 386 q14 10 28 0" fill="#ffe08a"/>',
    '<ellipse cx="354" cy="392" rx="22" ry="17" fill="#ff7a59" stroke="#2b2147" stroke-width="3"/>']),
  christmas: S(['<rect width="400" height="440" fill="#fde7d7"/>', '<rect x="260" y="50" width="110" height="110" rx="8" fill="#9fd3ff" stroke="#2b2147" stroke-width="4"/>',
    '<path d="M260 105 H370 M315 50 V160" stroke="#ffffff" stroke-width="4"/>', nightStars([[280, 70], [300, 130], [340, 80], [356, 140]]),
    '<rect y="388" width="400" height="52" fill="#e8c9a8"/>', '<path d="M60 120 L110 220 L90 220 L130 300 L100 300 L140 380 L-20 380 L20 300 L-10 300 L30 220 L10 220 Z" fill="#3fb08a" stroke="#2b2147" stroke-width="3" stroke-linejoin="round"/>',
    '<circle cx="50" cy="250" r="7" fill="#d13667"/>', '<circle cx="80" cy="320" r="7" fill="#ffc23d"/>', '<circle cx="30" cy="340" r="7" fill="#2a73c0"/>',
    '<path d="M60 102 l5 12 13 1 -10 8 3 13 -11 -7 -11 7 3 -13 -10 -8 13 -1 z" fill="#ffc23d" stroke="#2b2147" stroke-width="2"/>',
    '<rect x="300" y="350" width="44" height="38" rx="4" fill="#d13667" stroke="#2b2147" stroke-width="3"/>', '<path d="M322 350 V388 M300 368 H344" stroke="#ffc23d" stroke-width="5"/>']),
  bedtime: S(['<rect width="400" height="440" fill="#3a3170"/>', '<path d="M350 52 A30 30 0 1 1 318 22 A24 24 0 0 0 350 52 Z" fill="#ffc23d"/>', '<rect y="388" width="400" height="52" fill="#4b3f8a"/>',
    nightStars([[40, 50], [90, 120], [150, 40], [250, 90], [370, 150], [30, 220], [370, 260], [60, 330]])])
};

/* Weather drawn over outdoor scenes. */
function rainDrops() {
  let g = '';
  for (let i = 0; i < 22; i++) { const x = 14 + (i * 53) % 380, y = 20 + (i * 97) % 340; g += '<path d="M' + x + ' ' + y + ' l-6 16" stroke="#5f93a8" stroke-width="4" stroke-linecap="round"/>'; }
  return g;
}
function snowFlakes() {
  let g = '';
  for (let i = 0; i < 30; i++) { const x = 10 + (i * 61) % 384, y = 10 + (i * 89) % 360; g += '<circle cx="' + x + '" cy="' + y + '" r="' + (3 + i % 3) + '" fill="#ffffff" stroke="#c7d6e2" stroke-width="1"/>'; }
  return g;
}
const WEATHER_OVERLAYS = {
  nice: '',
  rain: '<rect width="400" height="440" fill="#5f7d8c" opacity=".28"/><ellipse cx="90" cy="54" rx="80" ry="30" fill="#c9d6de"/><ellipse cx="300" cy="66" rx="96" ry="34" fill="#c9d6de"/>' + rainDrops() + '<ellipse cx="200" cy="424" rx="150" ry="16" fill="#9fc0cf"/>',
  snow: '<rect width="400" height="440" fill="#ffffff" opacity=".25"/><rect y="392" width="400" height="48" fill="#ffffff"/>' + snowFlakes(),
  cold: '<rect width="400" height="440" fill="#cfe3ff" opacity=".35"/><ellipse cx="300" cy="66" rx="96" ry="30" fill="#ffffff" opacity=".9"/>',
  hot: '<circle cx="330" cy="64" r="44" fill="#ffc23d" stroke="#ff7a59" stroke-width="4"/><path d="M330 4 v-0 M262 64 h-14 M398 64 h-14 M282 16 l-10 -10 M378 16 l10 -10" stroke="#ff7a59" stroke-width="5" stroke-linecap="round"/><rect width="400" height="440" fill="#ffd166" opacity=".12"/>'
};

/* ---------- icons (24 x 24, stroke = currentColor) ---------- */
const SUN = 'M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8z M12 2v2 M12 20v2 M4.9 4.9l1.4 1.4 M17.7 17.7l1.4 1.4 M2 12h2 M20 12h2 M4.9 19.1l1.4-1.4 M17.7 6.3l1.4-1.4';
const ICON_PATHS = {
  school: 'M3 6c3-1.3 6-1.3 9 1 3-2.3 6-2.3 9-1v13c-3-1-6-1-9 1-3-2-6-2-9-1z M12 7v13',
  park: 'M12 21v-6 M12 15a6 6 0 1 0 0-12 6 6 0 0 0 0 12z M9 21h6',
  beach: SUN,
  playground: 'M4 21V6h4v15 M4 10h4 M4 14h4 M8 6l11 13h2',
  kitchen: 'M7 14a4 4 0 1 1 1.5-7.7A4 4 0 0 1 16 5.5a4 4 0 1 1 1 8.5V20H7z M7 17h10',
  sleepover: 'M3 20L12 4l9 16z M12 4v16 M9 20l3-6 3 6',
  sports: 'M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18z M12 7l4 3-1.5 5h-5L8 10z M12 7V3 M16 10l4.5-1.5 M14.5 15l2.5 4 M9.5 15L7 19 M8 10L3.5 8.5',
  snowplay: 'M12 9a3 3 0 1 0 0-6 3 3 0 0 0 0 6z M12 21a6 6 0 1 0 0-12 6 6 0 0 0 0 12z M7 12L3 9 M17 12l4-3',
  swimming: 'M2 12c2-2 4-2 6 0s4 2 6 0 4-2 6 0 M2 18c2-2 4-2 6 0s4 2 6 0 4-2 6 0 M15 8a2 2 0 1 0 0-4 2 2 0 0 0 0 4z',
  ballet: 'M12 2.5a2 2 0 1 1 0 4 2 2 0 0 1 0-4z M12 7v6 M12 9l-6-3 M12 9l6-3 M7 19c2-3 3-6 5-6s3 3 5 6 M4 19h16',
  party: 'M12 2c3.3 0 5.5 2.6 5.5 5.7S15.2 14 12 14 6.5 10.8 6.5 7.7 8.7 2 12 2z M12 14l-1 2h2z M12 16c-1.5 2 1.5 3 0 6',
  birthday: 'M4 21h16v-8H4z M4 16c2 1.5 4 1.5 6 0s4-1.5 6 0 2 1.5 4 0 M12 13V9 M12 7a1.5 1.5 0 0 1-1.5-1.5c0-1 1.5-3 1.5-3s1.5 2 1.5 3A1.5 1.5 0 0 1 12 7z',
  halloween: 'M12 7c-5 0-8 3-8 7s3 7 8 7 8-3 8-7-3-7-8-7z M12 7c-2 2-2 12 0 14 M12 7c2 2 2 12 0 14 M12 7V4c1 0 2 .5 2.5 1.5',
  christmas: 'M12 2l5 7h-3l4 6h-4l3 5H7l3-5H6l4-6H7z M12 20v2',
  bedtime: 'M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z',
  nice: 'M10 3v1 M4.2 5.2l.8.8 M3 11h1 M14.6 8.4A4 4 0 0 0 6.2 10 M7 20a4 4 0 0 1-.2-8 5 5 0 0 1 9.6-1A3.6 3.6 0 0 1 17 20z',
  rain: 'M7 15a4 4 0 0 1-.2-8 5 5 0 0 1 9.6-1A3.6 3.6 0 0 1 17 15z M8 18l-1 3 M12 18l-1 3 M16 18l-1 3',
  snow: 'M12 2v20 M4 6l16 12 M20 6L4 18 M9 3l3 3 3-3 M9 21l3-3 3 3',
  cold: 'M14 14.8V4a2 2 0 0 0-4 0v10.8a4 4 0 1 0 4 0z M12 9v8',
  hot: SUN,
  top: 'M8 3L3 6l2 4 2-1v11h10V9l2 1 2-4-5-3a4 4 0 0 1-8 0z',
  bottom: 'M6 3h12l1 18h-5l-2-10-2 10H5z',
  dress: 'M9 3h6l-1 5 6 13H4l6-13z',
  coat: 'M8 3L4 6v15h6V9l2-2 2 2v12h6V6l-4-3-4 3z',
  shoes: 'M3 14c3 0 5-2 6-5l4 3c2 1.3 5 1.3 8 2.5V18H3z',
  hat: 'M5 17c0-6 3-11 7-11s7 5 7 11 M2 17h20',
  extra: 'M12 3l2.6 5.6 6 .7-4.5 4.1 1.2 6L12 16.6 6.7 19.4l1.2-6L3.4 9.3l6-.7z',
  check: 'M4 12l5 5L20 6',
  undo: 'M9 14L4 9l5-5 M4 9h10a6 6 0 0 1 0 12h-3',
  palette: 'M12 3a9 9 0 0 0 0 18c1.4 0 2-1 2-2 0-1.5-1-1.8-1-3 0-1 .8-2 2-2h2.5A3.5 3.5 0 0 0 21 10.5C21 6.4 17 3 12 3z M7.5 11.5h.01 M10 7.5h.01 M15 7.5h.01',
  calendar: 'M4 6h16v14H4z M4 10h16 M8 3v5 M16 3v5',
  lock: 'M6 11h12v10H6z M8 11V7a4 4 0 0 1 8 0v4',
  pin: 'M12 22s7-7 7-12a7 7 0 0 0-14 0c0 5 7 12 7 12z M12 12a2 2 0 1 0 0-4 2 2 0 0 0 0 4z',
  left: 'M15 5l-7 7 7 7',
  right: 'M9 5l7 7-7 7',
  plus: 'M12 5v14 M5 12h14',
  trash: 'M4 7h16 M9 7V4h6v3 M6 7l1 13h10l1-13',
  close: 'M6 6l12 12 M18 6L6 18'
};

module.exports = { INK, ITEMS, THUMBS, SLOTS, OCCASIONS, LOOKS, BACKDROPS, WEATHER_OVERLAYS, ICON_PATHS, parts };
