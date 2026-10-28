(function () {
  'use strict';

  /* =========================================================
     Storage & state
     ========================================================= */
  const KEY = 'damstock-state-v1';
  const PRICE_CAP = 30000000;
  const saved = (() => { try { return JSON.parse(localStorage.getItem(KEY)) || {}; } catch (e) { return {}; } })();

  const state = {
    lang: saved.lang || 'ar',
    onboarded: !!saved.onboarded,
    user: saved.user || null,
    notificationsOn: saved.notificationsOn !== false,
    fav: saved.fav || [],
    compare: saved.compare || [],
    inquiries: saved.inquiries || null,
    myListings: saved.myListings || [],
    tab: 'home',
    filter: defaultFilter(),
  };

  function persist() {
    try {
      localStorage.setItem(KEY, JSON.stringify({
        lang: state.lang, onboarded: state.onboarded, user: state.user, notificationsOn: state.notificationsOn,
        fav: state.fav, compare: state.compare, inquiries: state.inquiries, myListings: state.myListings,
      }));
    } catch (e) { /* storage unavailable */ }
  }

  function defaultFilter() {
    return { query: '', kind: null, types: [], city: null, minPrice: 0, maxPrice: PRICE_CAP, minBeds: 0, finish: null, ready: null, sort: 'newest' };
  }

  /* =========================================================
     Data
     ========================================================= */
  const DAY = 86400000;
  const img = (i, w = 1200) => `https://images.unsplash.com/${DATA.imgIds[i % DATA.imgIds.length]}?auto=format&fit=crop&w=${w}&q=80`;
  const devCover = (d) => `https://images.unsplash.com/${d.cover}?auto=format&fit=crop&w=1200&q=80`;

  const developers = DATA.developers;
  const projects = DATA.projects.map((p) => ({ ...p, images: p.images.map((i) => img(i)) }));
  const market = DATA.properties.map((p) => ({ ...p, images: p.images.map((i) => img(i)), listedAt: Date.now() - p.listedAt.ago * DAY }));
  const samplePhotos = Array.from({ length: 8 }, (_, i) => img(i + 4, 600));

  if (!state.inquiries) {
    state.inquiries = [
      { id: 'i-seed-1', type: 'viewing', propertyId: 'p3', name: 'Guest', phone: '01000000000', message: '', viewingDate: Date.now() + 2 * DAY, slot: '12:00', createdAt: Date.now() - DAY, status: 'confirmed' },
      { id: 'i-seed-2', type: 'info', projectId: 'pr4', name: 'Guest', phone: '01000000000', message: 'Payment plan for 2-bedroom chalets?', createdAt: Date.now() - 4 * DAY, status: 'completed' },
    ];
  }

  const notifications = [
    { icon: 'rocket_launch', t: ['إطلاق جديد', 'New launch'], b: ['أبراج مرسى العلمين متاحة الآن بمقدم 10%', 'Alamein Marina Towers now open with 10% down'], at: Date.now() - 2 * 3600000 },
    { icon: 'trending_down', t: ['انخفاض سعر', 'Price drop'], b: ['شقة إعادة بيع بالتجمع انخفض سعرها 4%', 'A New Cairo resale apartment dropped 4%'], at: Date.now() - 9 * 3600000 },
    { icon: 'event_available', t: ['تأكيد معاينة', 'Viewing confirmed'], b: ['تم تأكيد موعد معاينتك في زايد هايتس', 'Your Zayed Heights viewing is confirmed'], at: Date.now() - DAY },
  ];

  const allProps = () => [...state.myListings, ...market];
  const propById = (id) => allProps().find((p) => p.id === id);
  const devById = (id) => developers.find((d) => d.id === id);
  const projById = (id) => projects.find((p) => p.id === id);
  const pricePerMeter = (p) => (p.area ? Math.round(p.price / p.area) : 0);
  const monthlyOf = (p) => (p.installmentYears ? Math.round((p.price - (p.downPayment || 0)) / (p.installmentYears * 12)) : null);

  /* =========================================================
     i18n & formatting
     ========================================================= */
  const ar = () => state.lang === 'ar';
  const t = (k) => (STR[k] ? STR[k][ar() ? 0 : 1] : k);
  const tx = (o) => (o ? o[state.lang] : '');
  const kindLabel = (k) => t('kind_' + k);
  const typeLabel = (k) => t('type_' + k);
  const finishLabel = (k) => t('finish_' + k);
  const statusLabel = (k) => t('ps_' + k);
  const amenityLabel = (k) => t('am_' + k);
  const SORTS = { newest: 'sort_newest', priceLow: 'sort_price_low', priceHigh: 'sort_price_high', areaHigh: 'sort_area', pricePerMeter: 'sort_ppm' };
  const TYPES = ['apartment', 'villa', 'townhouse', 'twinhouse', 'duplex', 'penthouse', 'chalet', 'studio', 'office', 'clinic'];
  const FINISHES = ['core', 'semi', 'full', 'furnished'];
  const KINDS = ['primary', 'resale', 'assignment'];
  const TYPE_ICON = { apartment: 'apartment', villa: 'villa', townhouse: 'holiday_village', twinhouse: 'home_work', duplex: 'stairs', penthouse: 'roofing', chalet: 'beach_access', studio: 'bed', office: 'business_center', clinic: 'local_hospital' };
  const AMEN_ICON = { pool: 'pool', gym: 'fitness_center', security: 'shield', clubhouse: 'sports_tennis', parking: 'local_parking', kids: 'child_care', garden: 'park', mall: 'storefront', beach: 'beach_access', mosque: 'mosque', smart: 'sensors', spa: 'spa' };

  const esc = (s) => String(s == null ? '' : s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const num = (n) => Math.round(n).toLocaleString('en-US');
  const trim = (s) => (s.includes('.') ? s.replace(/0+$/, '').replace(/\.$/, '') : s);
  function price(p) {
    if (p >= 1e6) { const v = trim((p / 1e6).toFixed(p >= 1e7 ? 1 : 2)); return ar() ? `${v} مليون ج.م` : `EGP ${v}M`; }
    if (p >= 1e3) { const v = trim((p / 1e3).toFixed(p >= 1e5 ? 0 : 1)); return ar() ? `${v} ألف ج.م` : `EGP ${v}K`; }
    return full(p);
  }
  const full = (p) => (ar() ? `${num(p)} ج.م` : `EGP ${num(p)}`);
  const short = (p) => (p >= 1e6 ? trim((p / 1e6).toFixed(p >= 1e7 ? 1 : 2)) + 'M' : trim((p / 1e3).toFixed(0)) + 'K');
  const AR_DAYS = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
  const EN_DAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const AR_M = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
  const EN_M = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const dayName = (d) => (ar() ? AR_DAYS : EN_DAYS)[new Date(d).getDay()];
  const monthName = (d) => (ar() ? AR_M : EN_M)[new Date(d).getMonth()];
  const fmtDate = (d) => { const x = new Date(d); return ar() ? `${x.getDate()} ${monthName(d)}` : `${monthName(d)} ${x.getDate()}`; };
  function ago(ts) {
    const m = Math.floor((Date.now() - ts) / 60000);
    if (m < 1) return ar() ? 'الآن' : 'just now';
    if (m < 60) return ar() ? `منذ ${m} دقيقة` : `${m}m ago`;
    const h = Math.floor(m / 60);
    if (h < 24) return ar() ? `منذ ${h} ساعة` : `${h}h ago`;
    const d = Math.floor(h / 24);
    if (d === 1) return ar() ? 'منذ يوم' : '1 day ago';
    return ar() ? `منذ ${d} أيام` : `${d} days ago`;
  }
  const isMobile = (v) => /^01[0125][0-9]{8}$/.test(String(v).replace(/\s/g, ''));

  /* =========================================================
     UI helpers (return HTML strings)
     ========================================================= */
  const icon = (n, cls = '') => `<span class="ms ${cls}">${n}</span>`;
  const back = (dark = false) => `<button class="cbtn ${dark ? 'dark' : ''}" data-act="back" aria-label="back">${icon('arrow_back', 'flip')}</button>`;
  const im = (src, cls = '', style = '') => `<div class="img ${cls}" style="${style}"><img src="${esc(src)}" alt="" loading="lazy" onload="this.classList.add('ok')" onerror="this.parentNode.classList.add('fail')"></div>`;
  const tag = (label, cls = '', ic = '') => `<span class="tag ${cls}">${ic ? icon(ic) : ''}${esc(label)}</span>`;
  const pill = (label, on, attrs, ic = '', dense = false) => `<button class="pill ${on ? 'on' : ''} ${dense ? 'dense' : ''}" ${attrs}>${ic ? icon(ic) : ''}${esc(label)}</button>`;
  const favBtn = (id) => `<button class="fav ${state.fav.includes(id) ? 'on' : ''}" data-act="fav" data-id="${id}" aria-label="favorite">${icon('favorite')}</button>`;
  const sectionH = (title, sub, go, label) => `<div class="section-h"><div><h2 class="h2">${esc(title)}</h2>${sub ? `<p>${esc(sub)}</p>` : ''}</div>${go ? `<a href="${go}">${esc(label || t('see_all'))}${icon('chevron_right', 'flip')}</a>` : ''}</div>`;
  const empty = (ic, title, sub, label, attrs) => `<div class="empty"><div class="ico">${icon(ic)}</div><h3>${esc(title)}</h3><p>${esc(sub)}</p>${label ? `<button class="btn btn-forest inline" ${attrs}>${esc(label)}</button>` : ''}</div>`;
  function seg(labels, index, act, dark = false) {
    const n = labels.length;
    return `<div class="seg ${dark ? 'dark' : ''}"><span class="thumb" style="width:calc((100% - 8px)/${n});inset-inline-start:calc(4px + ${index} * (100% - 8px)/${n})"></span>${labels.map((l, i) => `<button class="${i === index ? 'on' : ''}" data-act="${act}" data-i="${i}">${esc(l)}</button>`).join('')}</div>`;
  }
  const counter = (label, value, min, max, act) => `<div class="counter"><b>${esc(label)}</b><button data-act="${act}" data-d="-1" ${value <= min ? 'disabled' : ''}>${icon('remove')}</button><span>${value}</span><button data-act="${act}" data-d="1" ${value >= max ? 'disabled' : ''}>${icon('add')}</button></div>`;
  const brandMark = (size = 56) => `<svg class="brand-mark" width="${size}" height="${size}" viewBox="0 0 100 100" aria-hidden="true"><path d="M10 44 L50 10 L90 44" fill="none" stroke="#D5B47A" stroke-width="6.5" stroke-linecap="round" stroke-linejoin="round"/><path d="M72 20 V30" stroke="#D5B47A" stroke-width="6.5" stroke-linecap="round"/><text x="50" y="86" text-anchor="middle" font-family="Plus Jakarta Sans, Inter, sans-serif" font-weight="800" font-size="46" fill="#D5B47A">D</text></svg>`;
  const wordmark = (size = 22, color = '#fff') => `<div class="brand-word"><b style="font-size:${size}px;letter-spacing:${size * 0.16}px;color:${color}">DAMSTOCK</b><small style="font-size:${size * 0.48}px;letter-spacing:${size * 0.55}px">HOMES</small></div>`;
  const devLogo = (d, size = 48) => `<span class="dlogo" style="width:${size}px;height:${size}px;font-size:${size * 0.42}px;background:linear-gradient(135deg, ${d.color}, ${shade(d.color)});${size <= 40 ? 'border-width:1.2px' : ''}">${d.letter}</span>`;
  function shade(hex) { const n = parseInt(hex.slice(1), 16); const f = (v) => Math.round(v * 0.65); return `rgb(${f(n >> 16)},${f((n >> 8) & 255)},${f(n & 255)})`; }

  function propertyCard(p, opts = {}) {
    const m = monthlyOf(p);
    const w = opts.width ? `style="width:${opts.width}px"` : '';
    return `<a class="pcard" href="#/property/${p.id}" ${w}>
      <div class="media" style="height:${opts.h || 190}px">${im(p.images[0])}<div class="shade"></div>
        <div class="tl">${tag(kindLabel(p.kind), 'k-' + p.kind)}${p.pendingReview ? tag(t('pending_review'), 'gold') : (p.verified !== false ? tag(t('verified'), 'glass', 'verified') : '')}</div>
        <div class="tr">${favBtn(p.id)}</div>
        <div class="bl">${icon(TYPE_ICON[p.type])}<span>${esc(typeLabel(p.type))}</span>${p.isReady ? tag(t('ready_now'), 'gold') : ''}</div>
      </div>
      <div class="body">
        <div class="row between"><span class="price ellipsis">${esc(price(p.price))}</span>${m ? `<span class="monthly">${esc(price(m))}${esc(t('per_month'))}</span>` : ''}</div>
        <div class="title ellipsis">${esc(tx(p.title))}</div>
        <div class="loc">${icon('location_on')}<span class="ellipsis">${esc(tx(p.location))} • ${esc(tx(p.city))}</span></div>
        <div class="specs">${p.beds ? `<span>${icon('king_bed')}${p.beds}</span>` : ''}<span>${icon('bathtub')}${p.baths}</span><span>${icon('square_foot')}${p.area} ${esc(t('sqm'))}</span><span class="ago">${esc(ago(p.listedAt))}</span></div>
      </div></a>`;
  }

  function projectCard(p, width) {
    const d = devById(p.developerId);
    return `<a class="prcard" href="#/project/${p.id}" ${width ? `style="width:${width}"` : ''}>${im(p.images[0])}<div class="shade"></div>
      <div class="st">${p.status === 'launch' ? tag(statusLabel(p.status), 'gold') : tag(statusLabel(p.status), 'glass')}</div>
      <div class="bt">
        ${d ? `<div class="dev">${devLogo(d, 24)}<span class="ellipsis">${esc(tx(d.name))}</span></div>` : ''}
        <h3>${esc(tx(p.name))}</h3>
        <div class="city">${icon('location_on')}${esc(tx(p.city))}</div>
        <div class="foot"><div class="from grow"><small>${esc(t('starting_from'))}</small><b>${esc(price(p.startingPrice))}</b></div>
          <div class="glass"><b>${p.downPaymentPct}%</b><small>${esc(t('down_payment'))}</small></div>
          <div class="glass"><b>${p.installmentYears} ${esc(t('years_short'))}</b><small>${esc(t('installments'))}</small></div></div>
      </div></a>`;
  }

  function projectTile(p) {
    const d = devById(p.developerId);
    return `<a class="ptile" href="#/project/${p.id}">${im(p.images[0])}<div class="grow">
      <div class="h3 ellipsis">${esc(tx(p.name))}</div>
      <div class="muted ellipsis" style="font-size:12px">${esc(d ? tx(d.name) : '')} • ${esc(tx(p.city))}</div>
      <div class="row between mt8"><b style="color:var(--forest)">${esc(price(p.startingPrice))}</b>${tag(t('delivery') + ' ' + p.deliveryYear, 'soft-gold')}</div>
      <div class="progress mt8"><i style="width:${p.progress * 100}%"></i></div></div></a>`;
  }

  function developerCard(d) {
    return `<a class="dcard" href="#/developer/${d.id}">
      <div class="cov">${im(devCover(d))}<div class="shade"></div>${tag(d.rating.toFixed(1), 'glass', 'star')}${devLogo(d, 58)}</div>
      <div class="body"><div class="h2" style="font-size:17px">${esc(tx(d.name))}</div><div class="muted" style="font-size:12.5px">${esc(tx(d.tagline))}</div>
      <div class="dstats"><div><b>${d.projectsCount}</b><span>${esc(t('projects'))}</span></div><div><b>${num(d.deliveredUnits)}+</b><span>${esc(t('delivered_units'))}</span></div><div><b>${d.founded}</b><span>${esc(t('founded'))}</span></div></div></div></a>`;
  }

  const amenGrid = (list) => `<div class="amen">${list.map((a) => `<div>${icon(AMEN_ICON[a] || 'check_circle')}<span>${esc(amenityLabel(a))}</span></div>`).join('')}</div>`;

  /* ---------- Map (stylised SVG) ---------- */
  function mapSvg(labels = true) {
    const P = DATA.cityPos;
    const pt = (c) => [P[c][0] * 1000, P[c][1] * 1000];
    let dots = '';
    for (let i = 0; i < 160; i++) { const x = ((i * 73) % 1000); const y = ((i * 131) % 1000); if (y > 160) dots += `<circle cx="${x}" cy="${y}" r="1.6" fill="rgba(213,180,122,.14)"/>`; }
    const greens = Object.keys(P).map((c) => { const [x, y] = pt(c); return `<rect x="${x - 80}" y="${y - 35}" width="160" height="70" rx="18" fill="#DDE7D9"/>`; }).join('');
    const links = [['Sheikh Zayed', 'New Cairo'], ['6th of October', 'Sheikh Zayed'], ['New Cairo', 'New Capital'], ['New Cairo', 'Mostakbal City'], ['New Capital', 'Ain Sokhna'], ['Sheikh Zayed', 'North Coast'], ['North Coast', 'New Alamein'], ['6th of October', 'New Cairo']];
    const roads = links.map(([a, b]) => { const [x1, y1] = pt(a); const [x2, y2] = pt(b); const d = `M${x1} ${y1} Q${(x1 + x2) / 2} ${(y1 + y2) / 2 - 12} ${x2} ${y2}`; return `<path d="${d}" stroke="#E6E1D6" stroke-width="6" fill="none" stroke-linecap="round"/><path d="${d}" stroke="#fff" stroke-width="4" fill="none" stroke-linecap="round"/>`; }).join('');
    const names = labels ? DATA.cities.map((c) => { const [x, y] = pt(c.en); return `<text x="${x}" y="${y + 34}" text-anchor="middle" font-size="15" font-weight="800" fill="rgba(23,59,52,.55)" font-family="Cairo, Inter, sans-serif">${esc(c[state.lang])}</text>`; }).join('') : '';
    return `<svg viewBox="0 0 1000 1000" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">
      <rect width="1000" height="1000" fill="#F1ECE1"/>
      <path d="M0 0 H1000 V50 Q600 100 350 60 Q150 100 0 140 Z" fill="#CFE3E3"/>
      <path d="M1000 620 Q930 780 950 1000 H1000 Z" fill="#CFE3E3"/>
      ${dots}${greens}
      <path d="M480 1000 C500 800 440 650 500 520 C520 400 450 280 500 100" stroke="#A9CDD0" stroke-width="7" fill="none" stroke-linecap="round"/>
      ${roads}${names}</svg>`;
  }

  function miniMap(x, y) {
    const W = 500, H = 360;
    const x0 = Math.min(Math.max(x * 1000 - W / 2, 0), 1000 - W);
    const y0 = Math.min(Math.max(y * 1000 - H / 2, 0), 1000 - H);
    const svg = mapSvg().replace('viewBox="0 0 1000 1000"', `viewBox="${x0} ${y0} ${W} ${H}"`);
    return `<div class="minimap" data-go="#/map"><div class="mapcanvas">${svg}</div>
      <div class="pin" style="left:${((x * 1000 - x0) / W) * 100}%;top:${((y * 1000 - y0) / H) * 100}%"><span class="home">${icon('home', 'fill')}</span></div>
      <span class="chip">${icon('open_in_full')}${esc(t('open_map'))}</span></div>`;
  }

  /* ---------- Calculator ---------- */
  const calcState = {};
  function calculator(key, priceV, down, years, editable = false) {
    const c = calcState[key] || (calcState[key] = { price: priceV, down: Math.min(Math.max(down, 0), 50), years: Math.min(Math.max(years, 0), 12) });
    return `<div class="card calc" data-calc="${key}">${calcInner(c, editable)}</div>`;
  }
  function calcInner(c, editable) {
    const downAmount = (c.price * c.down) / 100;
    const months = c.years * 12;
    const monthly = months ? (c.price - downAmount) / months : 0;
    return `<div class="head"><span class="ic">${icon('calculate')}</span><b style="font-size:16px">${esc(t('calculator'))}</b></div>
      ${editable ? `<div class="slider"><div class="lbl"><span>${esc(t('price_egp'))}</span><b>${esc(price(c.price))}</b></div><input type="range" min="1000000" max="30000000" step="500000" value="${c.price}" data-calcf="price" data-editable="1"></div>` : ''}
      <div class="slider"><div class="lbl"><span>${esc(t('down_payment'))}</span><b>${c.down}% • ${esc(price(downAmount))}</b></div><input type="range" min="0" max="50" step="5" value="${c.down}" data-calcf="down" ${editable ? 'data-editable="1"' : ''}></div>
      <div class="slider"><div class="lbl"><span>${esc(t('installments'))}</span><b>${c.years ? `${c.years} ${esc(t('years'))}` : esc(t('cash'))}</b></div><input type="range" min="0" max="12" step="1" value="${c.years}" data-calcf="years" ${editable ? 'data-editable="1"' : ''}></div>
      <div class="result"><div><small>${esc(t('monthly'))}</small><div class="big">${months ? esc(full(monthly)) : esc(t('cash'))}</div></div><div style="text-align:end"><small>${esc(t('down_payment'))}</small><b>${esc(price(downAmount))}</b></div></div>
      <p class="note">${esc(t('calc_note'))}</p>`;
  }

  /* =========================================================
     Router
     ========================================================= */
  const app = document.getElementById('app');
  const layer = document.getElementById('layer');
  let current = { name: '', params: [] };
  let afterRender = null;
  let historyDepth = 0;

  function parseHash() {
    const h = location.hash.replace(/^#\/?/, '');
    const [path, qs] = h.split('?');
    const parts = path.split('/').filter(Boolean);
    const query = Object.fromEntries(new URLSearchParams(qs || ''));
    return { name: parts[0] || '', params: parts.slice(1), query };
  }

  function go(hash, replace = false) {
    if (replace) { history.replaceState(null, '', hash); route(); } else { historyDepth++; location.hash = hash.replace(/^#/, ''); }
  }
  function goBack(fallback = '#/home') { if (historyDepth > 0) { historyDepth--; history.back(); } else go(fallback, true); }

  const TABS = ['home', 'explore', 'developers', 'resale', 'favorites'];

  function route(keepScroll = false) {
    const r = parseHash();
    document.documentElement.lang = state.lang;
    document.documentElement.dir = ar() ? 'rtl' : 'ltr';
    closeLayer();
    if (!r.name) { go(state.onboarded ? '#/home' : '#/splash', true); return; }
    const same = current.name === r.name && current.params.join('/') === r.params.join('/');
    const y = keepScroll && same ? window.scrollY : 0;
    current = r;
    afterRender = null;
    const screen = SCREENS[r.name] || SCREENS.home;
    if (TABS.includes(r.name)) state.tab = r.name;
    app.innerHTML = screen(r);
    app.classList.toggle('static', !!(keepScroll && same));
    if (app.firstElementChild) app.firstElementChild.classList.add('screen');
    window.scrollTo(0, y);
    if (afterRender) afterRender();
  }
  const rerender = () => route(true);
  window.addEventListener('hashchange', () => route());

  /* =========================================================
     Screens
     ========================================================= */
  const SCREENS = {};

  /* ---------- Splash ---------- */
  SCREENS.splash = () => {
    afterRender = () => setTimeout(() => { if (current.name === 'splash') go(state.onboarded ? '#/home' : '#/onboarding', true); }, 2400);
    return `<div class="splash"><div class="lines"></div><div class="center">${brandMark(96)}<div style="margin-top:22px">${wordmark(30)}</div><p style="margin:18px 0 0;font-weight:600;font-size:15px;color:rgba(255,255,255,.8)">${esc(t('tagline'))}</p></div><div class="bar"></div></div>`;
  };

  /* ---------- Onboarding ---------- */
  let obIndex = 0;
  const OB = [[2, 'ob1_title', 'ob1_body', 'travel_explore'], [7, 'ob2_title', 'ob2_body', 'insights'], [13, 'ob3_title', 'ob3_body', 'key']];
  SCREENS.onboarding = () => {
    const p = OB[obIndex];
    const last = obIndex === OB.length - 1;
    afterRender = () => {
      let sx = null;
      const el = app.querySelector('.onb');
      el.addEventListener('touchstart', (e) => { sx = e.touches[0].clientX; }, { passive: true });
      el.addEventListener('touchend', (e) => {
        if (sx == null) return; const dx = e.changedTouches[0].clientX - sx; sx = null;
        if (Math.abs(dx) < 50) return;
        const next = (dx < 0) !== ar();
        if (next && obIndex < OB.length - 1) { obIndex++; rerender(); } else if (!next && obIndex > 0) { obIndex--; rerender(); }
      });
    };
    return `<div class="onb"><div class="bg">${OB.map((o, i) => `<div style="position:absolute;inset:0;opacity:${i === obIndex ? 1 : 0};transition:opacity .6s">${im(img(o[0], 1400), '', 'position:absolute;inset:0')}</div>`).join('')}</div><div class="shade"></div>
      <div class="content">
        <div class="row">${brandMark(40)}<b style="font-family:var(--font-brand);letter-spacing:3px">DAMSTOCK</b><span class="grow"></span>
          <button class="chip-glass" data-act="lang">${icon('translate')}${ar() ? 'English' : 'العربية'}</button>
          ${last ? '' : `<button style="color:rgba(255,255,255,.85);font-weight:700;padding:6px" data-act="obFinish">${esc(t('skip'))}</button>`}</div>
        <div class="text" key="${obIndex}"><span class="icon-box">${icon(p[3])}</span><h1>${esc(t(p[1]))}</h1><p>${esc(t(p[2]))}</p></div>
        <div class="row mt24" style="margin-top:30px"><div class="dots">${OB.map((_, i) => `<i class="${i === obIndex ? 'on' : ''}"></i>`).join('')}</div><span class="grow"></span>
          <button class="btn btn-gold inline" data-act="obNext">${esc(t(last ? 'get_started' : 'next'))}${last ? icon('arrow_forward', 'flip') : ''}</button></div>
      </div></div>`;
  };

  /* ---------- Auth ---------- */
  const auth = { name: '', phone: '', from: '', code: '', err: {}, timer: 30, otpErr: false };
  let otpTimer = null;
  SCREENS.login = (r) => {
    auth.from = r.query.from || '';
    afterRender = () => {
      app.querySelector('#name').addEventListener('input', (e) => { auth.name = e.target.value; });
      app.querySelector('#phone').addEventListener('input', (e) => { e.target.value = e.target.value.replace(/\D/g, '').slice(0, 11); auth.phone = e.target.value; });
    };
    return `<div><div class="auth-hero">${im(img(0, 1400), '', 'position:absolute;inset:0')}<div class="shade"></div>
      <div class="top">${auth.from || historyDepth ? back(true) : '<span></span>'}<button class="cbtn dark" data-act="lang" aria-label="language">${icon('translate')}</button></div>${wordmark(26)}</div>
      <div class="sheet stagger">
        <h1 class="h1" style="font-size:26px">${esc(t('welcome_back'))}</h1>
        <p class="muted" style="margin:6px 0 24px">${esc(t('login_sub'))}</p>
        <div class="field"><label for="name">${esc(t('full_name'))}</label><div class="input ${auth.err.name ? 'err' : ''}">${icon('person')}<input id="name" autocomplete="name" value="${esc(auth.name)}"></div>${auth.err.name ? `<div class="errmsg">${esc(t('err_name'))}</div>` : ''}</div>
        <div class="field mt12"><label for="phone">${esc(t('mobile'))}</label><div class="input ltr ${auth.err.phone ? 'err' : ''}"><span class="prefix">🇪🇬 +20</span><input id="phone" inputmode="numeric" autocomplete="tel" placeholder="01XXXXXXXXX" value="${esc(auth.phone)}"></div>${auth.err.phone ? `<div class="errmsg">${esc(t('err_phone'))}</div>` : ''}</div>
        <div class="mt24"><button class="btn btn-forest" data-act="loginGo">${esc(t('continue'))}${icon('arrow_forward', 'flip')}</button></div>
        <div class="mt12"><button class="btn btn-outline" data-act="guest">${esc(t('guest'))}</button></div>
        <p class="muted" style="text-align:center;font-size:11.5px;margin-top:18px">${esc(t('terms_note'))}</p>
      </div></div>`;
  };

  SCREENS.otp = () => {
    const c = auth.code;
    afterRender = () => {
      const inp = app.querySelector('#otp');
      setTimeout(() => inp.focus(), 50);
      inp.addEventListener('input', () => {
        inp.value = inp.value.replace(/\D/g, '').slice(0, 4); auth.code = inp.value; auth.otpErr = false;
        const boxes = app.querySelectorAll('.otp div');
        boxes.forEach((b, i) => { b.textContent = auth.code[i] || ''; b.classList.toggle('fill', i < auth.code.length); b.classList.toggle('on', i === auth.code.length); });
        app.querySelector('.otp').classList.remove('err');
        app.querySelector('#otpmsg').innerHTML = `<span class="tag soft-gold">${icon('info')}${esc(t('otp_demo'))}</span>`;
        app.querySelector('[data-act="verify"]').disabled = auth.code.length < 4;
        if (auth.code.length === 4) verify();
      });
      clearInterval(otpTimer);
      otpTimer = setInterval(() => {
        if (current.name !== 'otp') return clearInterval(otpTimer);
        auth.timer = Math.max(0, auth.timer - 1);
        const el = app.querySelector('#resend'); if (!el) return;
        el.innerHTML = auth.timer ? `${esc(t('resend_in'))} 00:${String(auth.timer).padStart(2, '0')}` : `<button style="color:var(--gold-deep);font-weight:800" data-act="resend">${esc(t('resend'))}</button>`;
        if (!auth.timer) clearInterval(otpTimer);
      }, 1000);
    };
    return `<div><div class="topbar">${back()}<span class="grow"></span></div><div class="pad stagger">
      <div style="width:64px;height:64px;border-radius:20px;background:var(--forest);color:var(--gold);display:grid;place-items:center;margin-top:8px">${icon('sms')}</div>
      <h1 class="h1 mt20" style="font-size:26px">${esc(t('otp_title'))}</h1>
      <p class="muted" style="margin:6px 0 0">${esc(t('otp_sub'))}</p><b class="ltr" style="color:var(--forest);font-size:15px">+20 ${esc(auth.phone)}</b>
      <label class="mt24" style="display:block;position:relative" for="otp"><input id="otp" class="otp-input" inputmode="numeric" autocomplete="one-time-code" value="${esc(c)}">
        <div class="otp ${auth.otpErr ? 'err' : ''}">${[0, 1, 2, 3].map((i) => `<div class="${i < c.length ? 'fill' : ''} ${i === c.length ? 'on' : ''}">${esc(c[i] || '')}</div>`).join('')}</div></label>
      <div id="otpmsg" class="mt12">${auth.otpErr ? `<b style="color:var(--danger)">${esc(t('otp_wrong'))}</b>` : `<span class="tag soft-gold">${icon('info')}${esc(t('otp_demo'))}</span>`}</div>
      <p id="resend" class="muted" style="text-align:center;margin-top:22px">${esc(t('resend_in'))} 00:${String(auth.timer).padStart(2, '0')}</p>
      <div style="margin-top:40px"><button class="btn btn-forest" data-act="verify" ${c.length < 4 ? 'disabled' : ''}>${esc(t('verify'))}</button></div>
    </div></div>`;
  };

  function verify() {
    if (auth.code !== '1234') { auth.otpErr = true; if (navigator.vibrate) navigator.vibrate(60); const o = app.querySelector('.otp'); o.classList.remove('err'); void o.offsetWidth; o.classList.add('err'); app.querySelector('#otpmsg').innerHTML = `<b style="color:var(--danger)">${esc(t('otp_wrong'))}</b>`; return; }
    const b = app.querySelector('[data-act="verify"]'); b.innerHTML = '<span class="spinner"></span>'; b.disabled = true;
    setTimeout(() => {
      state.user = { name: auth.name.trim(), phone: auth.phone.trim() }; persist();
      toast(t('logged_in'));
      auth.code = ''; historyDepth = 0;
      go(auth.from ? '#/' + auth.from : '#/home', true);
    }, 700);
  }

  /* ---------- Tab shell ---------- */
  function navBar() {
    const items = [['home', 'home', 'tab_home'], ['explore', 'travel_explore', 'tab_explore'], ['developers', 'domain', 'tab_developers'], ['resale', 'swap_horiz', 'tab_resale'], ['favorites', 'favorite', 'tab_favorites']];
    return `<nav class="nav">${items.map(([k, ic, l]) => `<button class="${state.tab === k ? 'on' : ''}" data-go="#/${k}" data-replace="1"><span class="it">${icon(ic)}<span>${esc(t(l))}</span>${k === 'favorites' && state.fav.length ? `<em class="nb">${state.fav.length}</em>` : ''}</span></button>`).join('')}</nav>`;
  }
  const tabScreen = (inner) => `<div class="tabpad">${inner}${navBar()}</div>`;

  /* ---------- Home ---------- */
  SCREENS.home = () => {
    const featuredProjects = projects.filter((p) => p.featured);
    const featured = market.filter((p) => p.featured);
    const recent = [...market].sort((a, b) => b.listedAt - a.listedAt).slice(0, 4);
    const u = state.user;
    const cats = ['apartment', 'villa', 'townhouse', 'chalet', 'duplex', 'penthouse', 'office'];
    return tabScreen(`
      <header class="home-hero">${im(img(7))}<div class="in">
        <div class="row">${brandMark(38)}<div class="brand-word" style="text-align:start"><b style="font-size:14px;letter-spacing:2.5px">DAMSTOCK</b><small style="font-size:8px;letter-spacing:5px">HOMES</small></div><span class="grow"></span>
          <button class="cbtn dark" style="width:42px;height:42px" data-act="notifs" aria-label="notifications">${icon('notifications')}<span class="badge">${notifications.length}</span></button>
          <a class="avatar" href="#/profile">${u ? esc(u.name.trim().charAt(0).toUpperCase() || 'D') : icon('person', 'fill')}</a></div>
        <p style="margin:22px 0 4px;font-weight:600;color:rgba(255,255,255,.75)">${u ? `${esc(t('hello'))}${ar() ? '،' : ','} ${esc(u.name.split(' ')[0])}` : esc(t('hello_guest'))}</p>
        <h1 class="h1" style="font-size:26px">${esc(t('home_headline'))}</h1>
        <p style="margin:4px 0 18px;color:var(--gold);font-weight:700;font-size:13px">${esc(t('tagline'))}</p>
        <button class="search-fake" data-go="#/explore">${icon('search')}<span class="ellipsis" style="font-size:13.5px">${esc(t('search_hint'))}</span><span class="go">${icon('tune')}</span></button>
        <div class="hstats"><div><b>2,400+</b><span>${esc(t('stat_units'))}</span></div><div><b>${projects.length * 15}+</b><span>${esc(t('stat_projects'))}</span></div><div><b>${developers.length * 8}+</b><span>${esc(t('stat_devs'))}</span></div></div>
      </div></header>

      ${sectionH(t('categories'))}
      <div class="cats">${cats.map((c) => `<button class="cat press" data-act="exploreType" data-v="${c}"><span class="box">${icon(TYPE_ICON[c])}</span><span>${esc(typeLabel(c))}</span></button>`).join('')}</div>

      ${sectionH(t('featured_projects'), t('featured_projects_sub'), '#/projects')}
      <div class="carousel">${featuredProjects.map((p) => projectCard(p, '87%')).join('')}</div>

      ${sectionH(t('top_developers'), '', '#/developers')}
      <div class="cats">${developers.map((d) => `<a class="cat press" style="width:78px" href="#/developer/${d.id}">${devLogo(d, 66)}<span style="white-space:normal;line-height:1.25;font-size:11.5px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical">${esc(tx(d.name))}</span></a>`).join('')}</div>

      ${sectionH(t('featured_props'), '', '#/explore')}
      <div class="carousel">${featured.map((p) => propertyCard(p, { width: 272, h: 170 })).join('')}</div>

      ${sectionH(t('tools'))}
      <div class="tools">
        <a class="tool press" href="#/compare"><span class="ic">${icon('compare_arrows')}${state.compare.length ? `<span class="count">${state.compare.length}</span>` : ''}</span><span>${esc(t('tool_compare'))}</span></a>
        <a class="tool press" href="#/map"><span class="ic">${icon('map')}</span><span>${esc(t('tool_map'))}</span></a>
        <button class="tool press" data-act="calc"><span class="ic">${icon('calculate')}</span><span>${esc(t('tool_calc'))}</span></button>
        <a class="tool press" href="#/add"><span class="ic">${icon('add_home_work')}</span><span>${esc(t('tool_sell'))}</span></a>
      </div>

      <div class="mt24"><a class="banner press" href="#/add"><div class="grow"><h3>${esc(t('resale_banner_t'))}</h3><p>${esc(t('resale_banner_b'))}</p><span class="cta">${esc(t('list_now'))}</span></div><span class="key">${icon('key')}</span></a></div>

      ${sectionH(t('popular_areas'))}
      <div class="areas">${DATA.cities.slice(0, 6).map((c) => `<button class="area press" data-act="exploreCity" data-v="${esc(c.en)}">${im(img(DATA.cityCover[c.en] || 0, 600))}<div class="shade"></div><div class="t"><b>${esc(c[state.lang])}</b><span>${market.filter((p) => p.city.en === c.en).length} ${esc(t('units_count'))}</span></div></button>`).join('')}</div>

      ${sectionH(t('recent'), '', '#/explore')}
      <div class="pad stagger" style="display:grid;gap:16px">${recent.map((p) => propertyCard(p)).join('')}</div>
      <p class="muted" style="text-align:center;font-size:11px;margin-top:18px">© 2026 DAMSTOCK HOMES</p>`);
  };

  /* ---------- Explore ---------- */
  function applyFilter(list, f) {
    const q = f.query.trim().toLowerCase();
    const out = list.filter((p) => {
      if (q) { const hay = `${p.title.ar} ${p.title.en} ${p.location.ar} ${p.location.en} ${p.city.ar} ${p.city.en}`.toLowerCase(); if (!hay.includes(q)) return false; }
      if (f.kind && p.kind !== f.kind) return false;
      if (f.types.length && !f.types.includes(p.type)) return false;
      if (f.city && p.city.en !== f.city) return false;
      if (p.price < f.minPrice) return false;
      if (f.maxPrice < PRICE_CAP && p.price > f.maxPrice) return false;
      if (p.beds < f.minBeds) return false;
      if (f.finish && p.finish !== f.finish) return false;
      if (f.ready !== null && p.isReady !== f.ready) return false;
      return true;
    });
    const s = { newest: (a, b) => b.listedAt - a.listedAt, priceLow: (a, b) => a.price - b.price, priceHigh: (a, b) => b.price - a.price, areaHigh: (a, b) => b.area - a.area, pricePerMeter: (a, b) => pricePerMeter(a) - pricePerMeter(b) };
    return out.sort(s[f.sort]);
  }
  const activeCount = (f) => [f.types.length, f.city, f.minPrice > 0 || f.maxPrice < PRICE_CAP, f.minBeds, f.finish, f.ready !== null].filter(Boolean).length;

  function exploreResults() {
    const f = state.filter;
    const res = applyFilter(market, f);
    const anyFilter = activeCount(f) || f.kind || f.query;
    return `<div class="row" style="padding:12px 20px 4px"><b class="muted" style="font-size:13.5px">${res.length} ${esc(t('results'))}</b>
        ${anyFilter ? `<button style="color:var(--danger);font-weight:700;font-size:13px" data-act="clearFilters">${esc(t('clear_filters'))}</button>` : ''}<span class="grow"></span>
        <button class="row" style="gap:4px;color:var(--forest);font-weight:700;font-size:13px" data-act="sortMenu">${icon('swap_vert')}${esc(t(SORTS[f.sort]))}</button></div>
      ${res.length ? `<div class="pad stagger" style="display:grid;gap:16px;padding-top:8px">${res.map((p) => propertyCard(p)).join('')}</div>` : empty('search_off', t('no_results'), t('no_results_sub'), t('clear_filters'), 'data-act="clearFilters"')}`;
  }

  SCREENS.explore = () => {
    const f = state.filter;
    afterRender = () => {
      const inp = app.querySelector('#q');
      inp.addEventListener('input', () => { state.filter.query = inp.value; app.querySelector('#results').innerHTML = exploreResults(); });
    };
    return tabScreen(`
      <div class="row" style="padding:16px 20px 0"><h1 class="h1 grow">${esc(t('explore_title'))}</h1>
        <a class="cbtn" href="#/map" aria-label="map">${icon('map')}</a>
        <a class="cbtn" href="#/compare" aria-label="compare">${icon('compare_arrows')}${state.compare.length ? `<span class="badge">${state.compare.length}</span>` : ''}</a></div>
      <div class="row pad mt12"><div class="input grow">${icon('search')}<input id="q" type="search" placeholder="${esc(t('search_hint'))}" value="${esc(f.query)}"></div>
        <button class="press" style="position:relative;width:52px;height:52px;border-radius:16px;background:var(--forest);color:var(--gold);display:grid;place-items:center;flex:none" data-act="filters" aria-label="filters">${icon('tune')}${activeCount(f) ? `<span class="badge">${activeCount(f)}</span>` : ''}</button></div>
      <div class="hscroll mt12">${pill(t('all'), !f.kind, 'data-act="kind" data-v=""')}${KINDS.map((k) => pill(kindLabel(k), f.kind === k, `data-act="kind" data-v="${k}"`)).join('')}</div>
      <div id="results" style="position:relative">${exploreResults()}</div>`);
  };

  function filterSheet() {
    const f = JSON.parse(JSON.stringify(state.filter));
    const render = () => {
      const count = applyFilter(market, f).length;
      const sec = (title, body) => `<div style="margin-bottom:22px"><h3 class="h3" style="margin-bottom:10px">${esc(title)}</h3>${body}</div>`;
      return `<div class="grab"></div>
        <div class="row" style="padding:10px 12px 6px 20px"><h2 class="h2 grow" style="font-size:20px">${esc(t('filters'))}</h2>
          <button style="color:var(--gold-deep);font-weight:700;padding:8px" data-f="reset">${esc(t('reset'))}</button><button class="cbtn" style="box-shadow:none" data-f="close">${icon('close')}</button></div>
        <div class="scroll">
          ${sec(t('listing_kind'), `<div class="row wrap gap8">${pill(t('all'), !f.kind, 'data-f="kind" data-v=""')}${KINDS.map((k) => pill(kindLabel(k), f.kind === k, `data-f="kind" data-v="${k}"`)).join('')}</div>`)}
          ${sec(t('property_type'), `<div class="row wrap gap8">${TYPES.map((k) => pill(typeLabel(k), f.types.includes(k), `data-f="type" data-v="${k}"`, TYPE_ICON[k], true)).join('')}</div>`)}
          ${sec(t('city'), `<div class="row wrap gap8">${pill(t('all'), !f.city, 'data-f="city" data-v=""', '', true)}${DATA.cities.map((c) => pill(c[state.lang], f.city === c.en, `data-f="city" data-v="${esc(c.en)}"`, '', true)).join('')}</div>`)}
          ${sec(t('price_range'), `<div class="row"><div class="card bordered grow" style="padding:12px;text-align:center;font-weight:800;color:var(--forest)">${esc(price(f.minPrice))}</div><span>—</span><div class="card bordered grow" style="padding:12px;text-align:center;font-weight:800;color:var(--forest)">${f.maxPrice >= PRICE_CAP ? esc(t('no_limit')) : esc(price(f.maxPrice))}</div></div>
            <input type="range" min="0" max="${PRICE_CAP}" step="500000" value="${f.minPrice}" data-f="min" aria-label="min"><input type="range" min="0" max="${PRICE_CAP}" step="500000" value="${f.maxPrice}" data-f="max" aria-label="max">`)}
          ${sec(t('bedrooms'), `<div class="row wrap gap8">${[0, 1, 2, 3, 4, 5].map((b) => pill(b === 0 ? t('any') : b + '+', f.minBeds === b, `data-f="beds" data-v="${b}"`)).join('')}</div>`)}
          ${sec(t('finishing'), `<div class="row wrap gap8">${pill(t('any'), !f.finish, 'data-f="finish" data-v=""', '', true)}${FINISHES.map((k) => pill(finishLabel(k), f.finish === k, `data-f="finish" data-v="${k}"`, '', true)).join('')}</div>`)}
          ${sec(t('status'), seg([t('any'), t('ready'), t('offplan')], f.ready === null ? 0 : f.ready ? 1 : 2, 'fready'))}
        </div>
        <div class="foot"><button class="btn btn-forest" data-f="apply">${esc(t('show_results'))} (${count})</button></div>`;
    };
    const sheet = openSheet(render());
    const redraw = () => { const s = sheet.querySelector('.scroll').scrollTop; sheet.innerHTML = render(); sheet.querySelector('.scroll').scrollTop = s; };
    sheet.addEventListener('click', (e) => {
      const b = e.target.closest('[data-f],[data-act="fready"]'); if (!b) return;
      if (b.dataset.act === 'fready') { const i = +b.dataset.i; f.ready = i === 0 ? null : i === 1; return redraw(); }
      const k = b.dataset.f, v = b.dataset.v;
      if (k === 'close') return closeLayer();
      if (k === 'reset') { Object.assign(f, defaultFilter(), { query: f.query }); return redraw(); }
      if (k === 'apply') { state.filter = f; closeLayer(); return rerender(); }
      if (k === 'kind') f.kind = v || null;
      if (k === 'type') f.types = f.types.includes(v) ? f.types.filter((x) => x !== v) : [...f.types, v];
      if (k === 'city') f.city = v || null;
      if (k === 'beds') f.minBeds = +v;
      if (k === 'finish') f.finish = v || null;
      redraw();
    });
    sheet.addEventListener('change', (e) => {
      const k = e.target.dataset.f; const v = +e.target.value;
      if (k === 'min') f.minPrice = Math.min(v, f.maxPrice);
      if (k === 'max') f.maxPrice = Math.max(v, f.minPrice);
      redraw();
    });
  }

  function sortMenu(btn) {
    const old = app.querySelector('.sortmenu'); if (old) { old.remove(); return; }
    const m = document.createElement('div');
    m.className = 'sortmenu';
    m.innerHTML = Object.keys(SORTS).map((k) => `<button class="${state.filter.sort === k ? 'on' : ''}" data-act="sort" data-v="${k}">${esc(t(SORTS[k]))}</button>`).join('');
    btn.parentNode.after(m);
  }

  /* ---------- Developers ---------- */
  let devSeg = 0, devQ = '';
  SCREENS.developers = () => {
    afterRender = () => {
      const inp = app.querySelector('#dq');
      inp.addEventListener('input', () => { devQ = inp.value.trim(); app.querySelector('#dlist').innerHTML = devList(); app.querySelector('#dseg').innerHTML = devSegHtml(); });
    };
    return tabScreen(`<div style="padding:16px 20px 14px"><h1 class="h1">${esc(t('developers_title'))}</h1>
      <div class="input mt12">${icon('search')}<input id="dq" type="search" placeholder="${esc(t('search_dev'))}" value="${esc(devQ)}"></div>
      <div id="dseg" class="mt12">${devSegHtml()}</div></div><div id="dlist">${devList()}</div>`);
  };
  const match = (a, b) => !devQ || `${a} ${b}`.toLowerCase().includes(devQ.toLowerCase());
  const devFiltered = () => developers.filter((d) => match(d.name.ar, d.name.en));
  const projFiltered = () => projects.filter((p) => match(`${p.name.ar} ${p.city.ar}`, `${p.name.en} ${p.city.en}`));
  const devSegHtml = () => seg([`${t('tab_developers')} (${devFiltered().length})`, `${t('projects')} (${projFiltered().length})`], devSeg, 'devSeg');
  function devList() {
    const list = devSeg === 0 ? devFiltered() : projFiltered();
    if (!list.length) return empty(devSeg === 0 ? 'domain_disabled' : 'location_city', t('no_results'), t('no_results_sub'));
    return `<div class="pad stagger" style="display:grid;gap:${devSeg === 0 ? 16 : 14}px">${list.map((x) => (devSeg === 0 ? developerCard(x) : projectTile(x))).join('')}</div>`;
  }

  SCREENS.developer = (r) => {
    const d = devById(r.params[0]);
    if (!d) return notFound();
    const prj = projects.filter((p) => p.developerId === d.id);
    const units = market.filter((p) => p.developerId === d.id);
    const stat = (ic, v, l) => `<div class="card" style="flex:1;padding:14px 8px;text-align:center">${icon(ic)}<b style="display:block;color:var(--forest);font-size:16px;margin-top:6px">${v}</b><span class="muted ellipsis" style="display:block;font-size:11px">${esc(l)}</span></div>`;
    return `<div class="withbar">
      <div style="position:relative;height:300px;color:#fff">${im(devCover(d), '', 'position:absolute;inset:0')}<div style="position:absolute;inset:0;background:linear-gradient(180deg,rgba(16,44,39,.3),rgba(16,44,39,.95))"></div>
        <div style="position:absolute;top:12px;inset-inline-start:16px">${back(true)}</div>
        <div class="row" style="position:absolute;inset-inline:20px;bottom:22px;align-items:flex-end;gap:14px">${devLogo(d, 76)}<div class="grow">${tag(d.rating.toFixed(1), 'gold', 'star')}<h1 class="h1" style="font-size:22px;margin-top:6px">${esc(tx(d.name))}</h1><p style="margin:0;font-size:13px;color:rgba(255,255,255,.8)">${esc(tx(d.tagline))}</p></div></div></div>
      <div class="row pad mt20" style="color:var(--gold)">${stat('location_city', d.projectsCount, t('projects'))}${stat('key', num(d.deliveredUnits) + '+', t('delivered_units'))}${stat('event', d.founded, t('founded'))}</div>
      <div class="pad mt24"><h2 class="h2">${esc(t('about_dev'))}</h2><p class="para">${esc(tx(d.about))}</p>
        <div class="loc" style="color:var(--ink);font-weight:700;font-size:13px;margin-top:10px">${icon('location_on')}${esc(t('hq'))}: ${esc(tx(d.hq))}</div></div>
      ${sectionH(t('dev_projects'))}<div class="pad stagger" style="display:grid;gap:12px">${prj.map(projectTile).join('')}</div>
      ${units.length ? `${sectionH(t('available_units'))}<div class="carousel">${units.map((p) => propertyCard(p, { width: 272, h: 170 })).join('')}</div>` : ''}
      <div class="bottombar"><button class="btn btn-gold" data-go="#/inquiry?type=callback&dev=${d.id}">${icon('support_agent')}${esc(t('contact_dev'))}</button></div></div>`;
  };

  /* ---------- Projects ---------- */
  let projStatus = '';
  SCREENS.projects = () => {
    const list = projects.filter((p) => !projStatus || p.status === projStatus);
    return `<div><div class="topbar">${back()}<span class="title">${esc(t('all_projects'))}</span><span class="spacer"></span></div>
      <div class="hscroll">${pill(t('all'), !projStatus, 'data-act="projStatus" data-v=""')}${['launch', 'construction', 'delivered'].map((s) => pill(statusLabel(s), projStatus === s, `data-act="projStatus" data-v="${s}"`)).join('')}</div>
      <div class="pad stagger" style="display:grid;gap:16px;padding-top:14px">${list.map((p) => projectCard(p)).join('')}</div></div>`;
  };

  function galleryHtml(images, tags) {
    return `<div class="gallery"><div class="track">${images.map((src, i) => `<div style="flex:none;width:100%;height:100%;scroll-snap-align:start" data-act="fullgal" data-i="${i}">${im(src, '', 'width:100%;height:100%')}</div>`).join('')}</div><div class="shade"></div>
      <div class="tags">${tags}</div><span class="counter-chip">${icon('photo_library')}<span id="gcount">1/${images.length}</span></span></div>`;
  }
  function bindGallery(images) {
    const tr = app.querySelector('.gallery .track'); if (!tr) return;
    tr.addEventListener('scroll', () => { const i = Math.round(Math.abs(tr.scrollLeft) / tr.clientWidth); const c = app.querySelector('#gcount'); if (c) c.textContent = `${i + 1}/${images.length}`; }, { passive: true });
  }

  SCREENS.project = (r) => {
    const p = projById(r.params[0]);
    if (!p) return notFound();
    const d = devById(p.developerId);
    const units = market.filter((x) => x.projectId === p.id);
    afterRender = () => {
      bindGallery(p.images); floatBar();
      setTimeout(() => { const b = app.querySelector('#progress'); if (b) b.style.width = p.progress * 100 + '%'; }, 80);
    };
    const fact = (ic, l, v) => `<div>${icon(ic)}<b>${esc(v)}</b><span>${esc(l)}</span></div>`;
    return `<div class="withbar">
      ${floatBarHtml(tx(p.name))}
      ${galleryHtml(p.images, tag(statusLabel(p.status), 'gold'))}
      <div class="dsheet">
        <h1 class="h1" style="font-size:28px">${esc(tx(p.name))}</h1>
        <div class="loc" style="font-size:13px">${icon('location_on')}${esc(tx(p.location))} • ${esc(tx(p.city))}</div>
        ${d ? `<a class="card linkcard mt16" href="#/developer/${d.id}">${devLogo(d, 44)}<div class="grow"><small class="muted">${esc(t('developer'))}</small><div class="h3">${esc(tx(d.name))}</div></div>${tag(d.rating.toFixed(1), 'soft-gold', 'star')}${icon('chevron_right', 'flip muted')}</a>` : ''}
        <div class="facts mt16">${fact('payments', t('starting_from'), price(p.startingPrice))}${fact('event_available', t('delivery'), p.deliveryYear)}${fact('percent', t('down_payment'), p.downPaymentPct + '%')}${fact('date_range', t('installments'), `${p.installmentYears} ${t('years')}`)}${fact('square_foot', t('area_range'), `${p.minArea}–${p.maxArea}`)}${fact('landscape', t('project_size'), `${p.acres} ${t('acres')}`)}</div>
        <div class="card mt20" style="padding:16px"><div class="row between"><b>${esc(t('construction_progress'))}</b><b style="color:var(--gold-deep);font-size:16px">${Math.round(p.progress * 100)}%</b></div>
          <div class="progress mt12" style="height:10px;border-radius:6px"><i id="progress" style="width:0;background:var(--forest);transition:width 1.1s cubic-bezier(.2,.8,.2,1)"></i></div></div>
        <h2 class="h2 mt24">${esc(t('about_project'))}</h2><p class="para">${esc(tx(p.description))}</p>
        <h2 class="h2 mt20">${esc(t('unit_types'))}</h2><div class="row wrap gap8 mt12">${p.unitTypes.map((u) => pill(typeLabel(u), false, '', TYPE_ICON[u], true)).join('')}</div>
        <h2 class="h2 mt24">${esc(t('amenities'))}</h2><div class="mt12">${amenGrid(p.amenities)}</div>
        <div class="mt24">${calculator('proj-' + p.id, p.startingPrice, p.downPaymentPct, p.installmentYears)}</div>
        <h2 class="h2 mt24">${esc(t('location'))}</h2><div class="mt12">${miniMap(p.x, p.y)}</div>
      </div>
      ${sectionH(t('available_units'))}
      ${units.length ? `<div class="pad" style="display:grid;gap:16px">${units.map((u) => propertyCard(u)).join('')}</div>` : `<div class="pad"><div class="card" style="padding:18px" class="muted">${esc(t('no_units'))}</div></div>`}
      <div class="bottombar"><a class="ract" href="#/inquiry?type=callback&project=${p.id}" style="border:1.2px solid rgba(23,59,52,.25);background:none">${icon('phone_in_talk')}</a>
        <button class="btn btn-gold" data-go="#/inquiry?type=viewing&project=${p.id}">${icon('event_available')}${esc(t('book_viewing'))}</button></div></div>`;
  };

  /* ---------- Property details ---------- */
  function floatBarHtml(title, favId) {
    return `<div class="floatbar" id="fbar">${back(true)}<span class="ttl">${esc(title)}</span><button class="cbtn dark" data-act="share" aria-label="share">${icon('share')}</button>${favId ? favBtn(favId).replace('class="fav', 'style="width:44px;height:44px" class="fav') : ''}</div>`;
  }
  let fbarHandler = null;
  function floatBar() {
    const bar = app.querySelector('#fbar'); if (!bar) return;
    if (fbarHandler) window.removeEventListener('scroll', fbarHandler);
    fbarHandler = () => { const b = app.querySelector('#fbar'); if (b) b.classList.toggle('solid', window.scrollY > 300); };
    window.addEventListener('scroll', fbarHandler, { passive: true });
    fbarHandler();
  }

  SCREENS.property = (r) => {
    const p = propById(r.params[0]);
    if (!p) return notFound();
    const d = devById(p.developerId);
    const pr = projById(p.projectId);
    const similar = market.filter((o) => o.id !== p.id && (o.city.en === p.city.en || o.type === p.type)).slice(0, 6);
    const inCmp = state.compare.includes(p.id);
    const m = monthlyOf(p);
    afterRender = () => { bindGallery(p.images); floatBar(); };
    const spec = (ic, v, l) => `<div><span class="ic">${icon(ic)}</span><b>${esc(v)}</b><span>${esc(l)}</span></div>`;
    const row = (l, v) => `<div class="inforow"><span>${esc(l)}</span><b>${esc(v)}</b></div>`;
    let assign = '';
    if (p.kind === 'assignment' && p.paidAmount) {
      const contract = p.originalPrice || p.price; const over = p.price - contract;
      assign = `<div class="assign mt16"><div class="row">${icon('swap_horiz')}<b style="color:#fff;font-size:16px">${esc(kindLabel('assignment'))}</b></div>
        <div class="cols"><div><small>${esc(t('original_price'))}</small><b>${esc(price(contract))}</b></div><div><small>${esc(t('paid_amount'))}</small><b>${esc(price(p.paidAmount))}</b></div><div><small>${esc(t('remaining'))}</small><b>${esc(price(contract - p.paidAmount))}</b></div></div>
        <div class="bar"><i style="width:${Math.min(100, (p.paidAmount / contract) * 100)}%"></i></div>
        <p>${esc(t('overprice'))}: ${over >= 0 ? esc(full(over)) : '−' + esc(full(-over))} • ${esc(t('assignment_note'))}</p></div>`;
    }
    const link = pr || d;
    return `<div class="withbar">
      ${floatBarHtml(tx(p.title), p.id)}
      ${galleryHtml(p.images, tag(kindLabel(p.kind), 'k-' + p.kind) + (p.pendingReview ? tag(t('pending_review'), 'gold') : tag(t('verified'), 'glass', 'verified')) + (p.negotiable ? tag(t('negotiable'), 'glass') : ''))}
      <div class="dsheet">
        <div class="row" style="align-items:flex-start"><div class="grow"><div class="price" style="font-size:24px">${esc(full(p.price))}</div>${m ? `<div class="monthly" style="font-size:13px;font-weight:700">${esc(full(m))} ${esc(t('per_month'))}</div>` : ''}</div>
          <button class="pill dense ${inCmp ? 'on' : ''}" data-act="compare" data-id="${p.id}">${icon(inCmp ? 'check' : 'compare_arrows')}${esc(t(inCmp ? 'in_compare' : 'add_compare'))}</button></div>
        <h1 class="h1 mt8" style="font-size:21px">${esc(tx(p.title))}</h1>
        <div class="loc" style="font-size:13.5px">${icon('location_on')}${esc(tx(p.location))} • ${esc(tx(p.city))}</div>
        <div class="card specbox mt16">${p.beds ? spec('king_bed', p.beds, t('beds')) : ''}${spec('bathtub', p.baths, t('baths'))}${spec('square_foot', p.area, t('sqm'))}${spec('layers', p.floor == null ? '—' : p.floor === 0 ? t('ground') : p.floor, t('floor'))}</div>
        <div class="card inforows mt12">${row(t('type'), typeLabel(p.type))}${row(t('finishing'), finishLabel(p.finish))}${row(t('delivery'), p.isReady ? t('ready_now') : p.deliveryYear)}${row(t('price_per_m'), full(pricePerMeter(p)))}${p.sellerName ? row(t('seller'), p.sellerName) : row(t('listing_kind'), kindLabel(p.kind))}</div>
        ${assign}
        ${link ? `<a class="card linkcard mt12" href="${pr ? '#/project/' + pr.id : '#/developer/' + d.id}">${pr ? im(pr.images[0], '', 'width:56px;height:56px;border-radius:14px;flex:none') : devLogo(d, 56)}<div class="grow"><small class="muted">${esc(t(pr ? 'project' : 'developer'))}</small><div class="h3">${esc(tx(pr ? pr.name : d.name))}</div>${pr && d ? `<small style="color:var(--gold-deep);font-weight:700">${esc(tx(d.name))}</small>` : ''}</div>${icon('chevron_right', 'flip muted')}</a>` : ''}
        <h2 class="h2 mt24">${esc(t('about_property'))}</h2><p class="para">${esc(tx(p.description))}</p>
        ${p.amenities && p.amenities.length ? `<h2 class="h2 mt24">${esc(t('amenities'))}</h2><div class="mt12">${amenGrid(p.amenities)}</div>` : ''}
        ${p.installmentYears ? `<div class="mt24">${calculator('prop-' + p.id, p.price, Math.round(((p.downPayment || 0) / p.price) * 100), p.installmentYears)}</div>` : ''}
        <h2 class="h2 mt24">${esc(t('location'))}</h2><div class="mt12">${miniMap(p.x, p.y)}</div>
      </div>
      ${similar.length ? `${sectionH(t('similar'))}<div class="carousel">${similar.map((s) => propertyCard(s, { width: 272, h: 170 })).join('')}</div>` : ''}
      <div class="bottombar">
        <button class="ract" data-act="call" aria-label="call">${icon('phone')}</button>
        <button class="ract wa" data-act="whatsapp" aria-label="whatsapp">${icon('chat')}</button>
        <a class="ract" href="#/inquiry?type=info&property=${p.id}" aria-label="inquire">${icon('mail')}</a>
        <button class="btn btn-gold" data-go="#/inquiry?type=viewing&property=${p.id}">${icon('event_available')}${esc(t('book_viewing'))}</button></div></div>`;
  };

  function fullGallery(images, start) {
    layer.innerHTML = `<div class="fullgal"><div class="top"><button class="cbtn dark" data-close="1">${icon('close')}</button><span id="fgc">${start + 1} / ${images.length}</span></div>
      <div class="track" dir="ltr">${images.map((s) => `<div class="img" style="height:100%"><img src="${esc(s)}" alt="" class="ok" style="object-fit:contain"></div>`).join('')}</div></div>`;
    const tr = layer.querySelector('.track');
    tr.scrollLeft = start * tr.clientWidth;
    tr.addEventListener('scroll', () => { layer.querySelector('#fgc').textContent = `${Math.round(tr.scrollLeft / tr.clientWidth) + 1} / ${images.length}`; }, { passive: true });
    layer.querySelector('[data-close]').onclick = closeLayer;
  }

  /* ---------- Resale ---------- */
  let resaleSeg = 0, resaleInfo = false;
  SCREENS.resale = () => {
    const list = market.filter((p) => p.kind !== 'primary' && (resaleSeg === 0 || p.kind === (resaleSeg === 1 ? 'resale' : 'assignment'))).sort((a, b) => b.listedAt - a.listedAt);
    return tabScreen(`<header class="home-hero"><div class="in">
        <div class="row"><h1 class="h1 grow">${esc(t('resale_title'))}</h1><button class="cbtn dark" data-act="resaleInfo" aria-label="info">${icon('help')}</button></div>
        <p style="margin:4px 0 0;font-size:13px;color:rgba(255,255,255,.75)">${esc(t('resale_sub'))}</p>
        ${resaleInfo ? `<div class="row" style="align-items:flex-start;margin-top:14px;padding:14px;border-radius:16px;background:rgba(255,255,255,.08);border:1px solid rgba(213,180,122,.3);animation:fadeUp .3s both">${icon('lightbulb', '')}<div><b style="color:var(--gold)">${esc(t('resale_info_t'))}</b><p style="margin:4px 0 0;font-size:12.5px;line-height:1.6;color:rgba(255,255,255,.85)">${esc(t('resale_info_b'))}</p></div></div>` : ''}
        <div class="mt16">${seg([t('all'), kindLabel('resale'), kindLabel('assignment')], resaleSeg, 'resaleSeg', true)}</div>
        <div class="mt12"><a class="btn btn-gold sm" href="#/add">${icon('add_home_work')}${esc(t('sell_your_unit'))}</a></div></div></header>
      ${list.length ? `<div class="pad stagger" style="display:grid;gap:16px;padding-top:20px">${list.map((p) => propertyCard(p)).join('')}</div>` : empty('search_off', t('no_results'), t('no_results_sub'))}`);
  };

  /* ---------- Favorites ---------- */
  SCREENS.favorites = () => {
    const favs = allProps().filter((p) => state.fav.includes(p.id));
    return tabScreen(`<div class="row" style="padding:16px 20px 8px"><div class="grow"><h1 class="h1">${esc(t('favorites_title'))}</h1>${favs.length ? `<span class="muted">${favs.length} ${esc(t('units_count'))}</span>` : ''}</div>
        <a class="cbtn" href="#/compare">${icon('compare_arrows')}${state.compare.length ? `<span class="badge">${state.compare.length}</span>` : ''}</a></div>
      ${favs.length >= 2 ? `<div class="pad" style="margin:4px 0 8px"><button class="btn btn-outline sm" data-act="compareFavs">${icon('compare_arrows')}${esc(t('compare_selected'))}</button></div>` : ''}
      ${favs.length ? `<div class="pad stagger" style="display:grid;gap:16px;padding-top:8px">${favs.map((p) => propertyCard(p)).join('')}</div>` : empty('favorite', t('fav_empty'), t('fav_empty_sub'), t('start_exploring'), 'data-go="#/explore"')}`);
  };

  /* ---------- Compare ---------- */
  SCREENS.compare = () => {
    const items = state.compare.map(propById).filter(Boolean);
    if (!items.length) return `<div><div class="topbar">${back()}<span class="title">${esc(t('compare_title'))}</span><span class="spacer"></span></div>${empty('compare_arrows', t('compare_empty'), t('compare_empty_sub'), t('start_exploring'), 'data-go="#/explore"')}</div>`;
    const min = (f) => Math.min(...items.map(f));
    const best = { price: min((p) => p.price), ppm: min(pricePerMeter), area: Math.max(...items.map((p) => p.area)) };
    const ms = items.map(monthlyOf).filter((x) => x != null); const bestM = ms.length ? Math.min(...ms) : null;
    const multi = items.length > 1;
    const rows = [
      [t('listing_kind'), (p) => kindLabel(p.kind)], [t('type'), (p) => typeLabel(p.type)],
      [t('price'), (p) => price(p.price), (p) => p.price === best.price], [t('price_per_m'), (p) => full(pricePerMeter(p)), (p) => pricePerMeter(p) === best.ppm],
      [t('area'), (p) => `${p.area} ${t('sqm')}`, (p) => p.area === best.area], [t('beds'), (p) => (p.beds ? p.beds : '—')], [t('baths'), (p) => p.baths],
      [t('finishing'), (p) => finishLabel(p.finish)], [t('delivery'), (p) => (p.isReady ? t('ready_now') : p.deliveryYear), (p) => p.isReady],
      [t('down_payment'), (p) => (p.downPayment ? price(p.downPayment) : t('cash'))], [t('monthly'), (p) => (monthlyOf(p) ? price(monthlyOf(p)) : '—'), (p) => monthlyOf(p) != null && monthlyOf(p) === bestM],
      [t('city'), (p) => tx(p.city)],
    ];
    return `<div><div class="topbar">${back()}<span class="title">${esc(t('compare_title'))}</span><button style="color:var(--danger);font-weight:700" data-act="clearCompare">${esc(t('clear_all'))}</button></div>
      <div class="pad"><div class="row" style="margin-bottom:12px">${tag(t('best_value'), 'gold', 'workspace_premium')}<span class="muted">${items.length}/3</span></div>
      <div class="cmp-wrap"><table class="cmp"><tr class="head"><th></th>${items.map((p) => `<td><div class="thumb">${im(p.images[0], '', 'position:absolute;inset:0')}<a href="#/property/${p.id}" style="position:absolute;inset:0"></a><button class="x" data-act="compare" data-id="${p.id}">${icon('close')}</button></div><div class="mt8" style="font-size:12.5px;line-height:1.3">${esc(tx(p.title))}</div></td>`).join('')}${items.length < 3 ? `<td><button class="addslot" data-go="#/explore">${icon('add_circle')}${esc(t('add_more'))}</button></td>` : ''}</tr>
        ${rows.map(([l, v, b]) => `<tr><th>${esc(l)}</th>${items.map((p) => `<td class="${multi && b && b(p) ? 'best' : ''}">${esc(v(p))}</td>`).join('')}${items.length < 3 ? '<td></td>' : ''}</tr>`).join('')}</table></div>
      <p class="muted" style="font-size:11.5px;margin-top:18px">${esc(t('calc_note'))}</p></div></div>`;
  };

  /* ---------- Map ---------- */
  let mapKind = '', mapSel = null;
  SCREENS.map = () => {
    const props = market.filter((p) => !mapKind || p.kind === mapKind);
    const sel = props.find((p) => p.id === mapSel);
    const colors = { primary: '#173B34', resale: '#3A6A8C', assignment: '#C08A2E' };
    afterRender = () => initMapPan();
    return `<div class="map-wrap" id="mapwrap"><div class="map-stage" id="stage"><div class="mapcanvas">${mapSvg()}</div>
        ${props.map((p) => `<button class="ppin ${p.id === mapSel ? 'on' : ''}" style="left:${p.x * 100}%;top:${p.y * 100}%" data-act="pin" data-id="${p.id}"><b style="background:${colors[p.kind]}">${short(p.price)}</b><i style="border-top-color:${colors[p.kind]}"></i></button>`).join('')}</div>
      <div class="map-top"><div class="row">${back()}<div class="card grow" style="height:44px;display:flex;align-items:center;padding:0 14px;font-weight:800;border-radius:15px">${esc(t('map_title'))} • ${props.length}</div></div>
        <div class="hscroll" style="padding:10px 0 0">${pill(t('all'), !mapKind, 'data-act="mapKind" data-v=""', '', true)}${KINDS.map((k) => pill(kindLabel(k), mapKind === k, `data-act="mapKind" data-v="${k}"`, '', true)).join('')}</div></div>
      <div class="map-bottom">${sel ? `<a class="card preview" href="#/property/${sel.id}">${im(sel.images[0], '', 'width:100px;height:100px;border-radius:16px;flex:none')}<div class="grow">${tag(kindLabel(sel.kind), 'k-' + sel.kind)}<div class="h3 ellipsis mt8">${esc(tx(sel.title))}</div><div class="muted" style="font-size:12px">${esc(tx(sel.city))} • ${sel.area} ${esc(t('sqm'))}</div><div class="price" style="font-size:16px;margin-top:4px">${esc(price(sel.price))}</div></div>${favBtn(sel.id)}</a>` : `<div class="hint">${icon('touch_app')}<span>${esc(t('map_hint'))}</span></div>`}</div></div>`;
  };
  const mapView = { x: null, y: 0, s: 1 };
  function initMapPan() {
    const wrap = app.querySelector('#mapwrap'); const stage = app.querySelector('#stage');
    const W = wrap.clientWidth * 1.9, H = wrap.clientHeight * 1.25;
    stage.style.width = W + 'px'; stage.style.height = H + 'px';
    if (mapView.x === null) { mapView.x = -(W * 0.55 - wrap.clientWidth / 2); mapView.y = -(H * 0.55 - wrap.clientHeight / 2); }
    const apply = () => {
      const s = mapView.s; const minX = wrap.clientWidth - W * s - 80, minY = wrap.clientHeight - H * s - 80;
      mapView.x = Math.min(80, Math.max(minX, mapView.x)); mapView.y = Math.min(80, Math.max(minY, mapView.y));
      stage.style.transform = `translate(${mapView.x}px,${mapView.y}px) scale(${s})`;
    };
    apply();
    const pts = new Map(); let last = null, lastDist = null, moved = false;
    wrap.addEventListener('pointerdown', (e) => { if (e.target.closest('.map-top,.map-bottom')) return; pts.set(e.pointerId, e); last = { x: e.clientX, y: e.clientY }; moved = false; });
    wrap.addEventListener('pointermove', (e) => {
      if (!pts.has(e.pointerId)) return; pts.set(e.pointerId, e);
      if (pts.size === 2) {
        const [a, b] = [...pts.values()]; const dist = Math.hypot(a.clientX - b.clientX, a.clientY - b.clientY);
        if (lastDist) zoomAt((a.clientX + b.clientX) / 2, (a.clientY + b.clientY) / 2, dist / lastDist);
        lastDist = dist; moved = true; return;
      }
      const dx = e.clientX - last.x, dy = e.clientY - last.y; if (Math.abs(dx) + Math.abs(dy) > 3) moved = true;
      mapView.x += dx; mapView.y += dy; last = { x: e.clientX, y: e.clientY }; apply();
    });
    const up = (e) => { pts.delete(e.pointerId); lastDist = null; if (pts.size === 1) { const p = [...pts.values()][0]; last = { x: p.clientX, y: p.clientY }; } };
    wrap.addEventListener('pointerup', up); wrap.addEventListener('pointercancel', up);
    wrap.addEventListener('click', (e) => { if (moved) { e.stopPropagation(); e.preventDefault(); moved = false; return; } if (!e.target.closest('.ppin,.map-top,.map-bottom') && mapSel) { mapSel = null; rerender(); } }, true);
    wrap.addEventListener('wheel', (e) => { e.preventDefault(); zoomAt(e.clientX, e.clientY, e.deltaY < 0 ? 1.12 : 0.89); }, { passive: false });
    function zoomAt(cx, cy, f) {
      const r = wrap.getBoundingClientRect(); const s2 = Math.min(2.5, Math.max(0.6, mapView.s * f)); const k = s2 / mapView.s;
      const px = cx - r.left, py = cy - r.top; mapView.x = px - (px - mapView.x) * k; mapView.y = py - (py - mapView.y) * k; mapView.s = s2; apply();
    }
  }

  /* ---------- Inquiry ---------- */
  const SLOTS = ['10:00', '12:00', '14:00', '16:00', '18:00', '20:00'];
  let inq = null;
  const slotLabel = (s) => { const h = +s.split(':')[0]; const h12 = h > 12 ? h - 12 : h; return ar() ? `${h12}:00 ${h >= 12 ? 'م' : 'ص'}` : `${h12}:00 ${h >= 12 ? 'PM' : 'AM'}`; };
  SCREENS.inquiry = (r) => {
    const key = location.hash;
    if (!inq || inq.key !== key) inq = { key, type: r.query.type || 'info', name: state.user ? state.user.name : '', phone: state.user ? state.user.phone : '', msg: '', day: null, slot: null, wa: false, err: {} };
    const p = propById(r.query.property), pr = projById(r.query.project), d = devById(r.query.dev);
    const [cimg, ctitle, csub] = p ? [p.images[0], tx(p.title), price(p.price)] : pr ? [pr.images[0], tx(pr.name), `${t('starting_from')} ${price(pr.startingPrice)}`] : d ? [devCover(d), tx(d.name), tx(d.tagline)] : [null, t('general_inquiry'), t('brand_sub')];
    const today = new Date(); today.setHours(0, 0, 0, 0);
    const days = Array.from({ length: 10 }, (_, i) => today.getTime() + (i + 1) * DAY);
    const types = ['info', 'viewing', 'callback'];
    afterRender = () => {
      app.querySelector('#iname').addEventListener('input', (e) => { inq.name = e.target.value; });
      app.querySelector('#iphone').addEventListener('input', (e) => { e.target.value = e.target.value.replace(/\D/g, '').slice(0, 11); inq.phone = e.target.value; });
      app.querySelector('#imsg').addEventListener('input', (e) => { inq.msg = e.target.value; });
    };
    return `<div><div class="topbar">${back()}<span class="title">${esc(t('inquiry_title'))}</span><span class="spacer"></span></div><div class="pad">
      <div class="card linkcard">${cimg ? im(cimg, '', 'width:64px;height:64px;border-radius:14px;flex:none') : `<span style="width:64px;height:64px;border-radius:14px;background:var(--forest);display:grid;place-items:center;flex:none">${brandMark(40)}</span>`}<div class="grow"><div class="h3 ellipsis">${esc(ctitle)}</div><div class="ellipsis" style="color:var(--gold-deep);font-weight:700;font-size:12.5px">${esc(csub)}</div></div></div>
      <div class="mt20">${seg(types.map((x) => t('inq_' + x)), types.indexOf(inq.type), 'inqType')}</div>
      ${inq.type === 'viewing' ? `<div style="animation:fadeUp .3s both"><div class="field mt20"><label>${esc(t('choose_date'))}</label><div class="days">${days.map((ts) => `<button class="day ${inq.day === ts ? 'on' : ''}" data-act="inqDay" data-v="${ts}"><small>${esc(dayName(ts))}</small><b>${new Date(ts).getDate()}</b><span>${esc(monthName(ts))}</span></button>`).join('')}</div></div>
        <div class="field mt16"><label>${esc(t('choose_time'))}</label><div class="row wrap gap8">${SLOTS.map((s) => pill(slotLabel(s), inq.slot === s, `data-act="inqSlot" data-v="${s}"`, 'schedule')).join('')}</div></div></div>` : ''}
      <div class="field mt20"><label for="iname">${esc(t('full_name'))}</label><div class="input ${inq.err.name ? 'err' : ''}">${icon('person')}<input id="iname" value="${esc(inq.name)}" autocomplete="name"></div>${inq.err.name ? `<div class="errmsg">${esc(t('err_name'))}</div>` : ''}</div>
      <div class="field mt12"><label for="iphone">${esc(t('mobile'))}</label><div class="input ltr ${inq.err.phone ? 'err' : ''}">${icon('phone_iphone')}<input id="iphone" inputmode="numeric" placeholder="01XXXXXXXXX" value="${esc(inq.phone)}"></div>${inq.err.phone ? `<div class="errmsg">${esc(t('err_phone'))}</div>` : ''}</div>
      <div class="field mt12"><label for="imsg">${esc(t('message'))}</label><div class="input"><textarea id="imsg" rows="3" placeholder="${esc(t('message_hint'))}">${esc(inq.msg)}</textarea></div></div>
      <div class="field mt16"><label>${esc(t('contact_pref'))}</label><div class="row"><button class="copt ${!inq.wa ? 'on' : ''}" data-act="inqWa" data-v="0">${icon('phone')}${esc(t('call'))}</button><button class="copt ${inq.wa ? 'on' : ''}" data-act="inqWa" data-v="1">${icon('chat')}${esc(t('whatsapp'))}</button></div></div>
      <div class="mt24" style="margin-bottom:24px"><button class="btn btn-gold" data-act="inqSubmit">${icon('send')}${esc(t('submit_request'))}</button></div>
    </div></div>`;
  };
  function submitInquiry() {
    inq.err = { name: inq.name.trim().length < 2, phone: !isMobile(inq.phone) };
    if (inq.err.name || inq.err.phone) return rerender();
    if (inq.type === 'viewing' && (!inq.day || !inq.slot)) { if (navigator.vibrate) navigator.vibrate(60); return toast(t('err_slot'), 'error'); }
    const b = app.querySelector('[data-act="inqSubmit"]'); b.innerHTML = '<span class="spinner"></span>'; b.disabled = true;
    const r = parseHash();
    setTimeout(() => {
      state.inquiries.unshift({ id: 'i' + Date.now(), type: inq.type, propertyId: r.query.property, projectId: r.query.project, developerId: r.query.dev, name: inq.name.trim(), phone: inq.phone.trim(), message: inq.msg.trim(), viewingDate: inq.type === 'viewing' ? inq.day : null, slot: inq.type === 'viewing' ? inq.slot : null, viaWhatsApp: inq.wa, createdAt: Date.now(), status: 'pending' });
      persist(); inq = null;
      success(t('request_sent'), t('request_sent_sub'), t('view_requests'), t('done'), (ok) => { if (ok) go('#/inquiries', true); else goBack(); });
    }, 900);
  }

  SCREENS.inquiries = () => {
    const segI = +(parseHash().query.s || 0);
    const list = state.inquiries.filter((i) => (segI === 1 ? i.type === 'viewing' : segI === 2 ? i.type !== 'viewing' : true));
    const st = { pending: ['var(--warning)', 'hourglass_top'], confirmed: ['var(--success)', 'check_circle'], completed: ['var(--info)', 'task_alt'] };
    const ti = { viewing: 'event_available', info: 'mail', callback: 'phone_callback' };
    return `<div><div class="topbar">${back()}<span class="title">${esc(t('my_inquiries'))}</span><span class="spacer"></span></div>
      <div class="pad" style="margin-bottom:12px">${seg([t('all'), t('inq_viewing'), t('inq_info')], segI, 'inqSeg')}</div>
      ${list.length ? `<div class="pad stagger" style="display:grid;gap:12px">${list.map((i) => {
        const p = propById(i.propertyId), pr = projById(i.projectId), d = devById(i.developerId);
        const title = p ? tx(p.title) : pr ? tx(pr.name) : d ? tx(d.name) : t('general_inquiry');
        const pic = p ? p.images[0] : pr ? pr.images[0] : d ? devCover(d) : null;
        const href = p ? '#/property/' + p.id : pr ? '#/project/' + pr.id : d ? '#/developer/' + d.id : '';
        return `<a class="card" style="display:block;padding:12px" ${href ? `href="${href}"` : ''}><div class="row">${pic ? im(pic, '', 'width:62px;height:62px;border-radius:14px;flex:none') : ''}<div class="grow">
          <div class="row" style="gap:4px"><span class="ms" style="font-size:15px;color:var(--gold-deep)">${ti[i.type]}</span><b style="font-size:12px;color:var(--gold-deep)">${esc(t('inq_' + i.type))}</b><span class="grow"></span><span class="tag soft" style="color:${st[i.status][0]};background:color-mix(in srgb, ${st[i.status][0]} 12%, transparent)">${icon(st[i.status][1])}${esc(t('st_' + i.status))}</span></div>
          <div class="h3 ellipsis mt8">${esc(title)}</div><small class="muted">${esc(ago(i.createdAt))}</small></div></div>
          ${i.type === 'viewing' && i.viewingDate ? `<div class="row" style="margin-top:10px;padding:10px 12px;border-radius:12px;background:var(--ivory)">${icon('calendar_month')}<span class="muted" style="font-size:12.5px">${esc(t('viewing_on'))}</span><span class="grow"></span><b style="font-size:12.5px">${esc(dayName(i.viewingDate))} ${esc(fmtDate(i.viewingDate))} • ${esc(i.slot || '')}</b></div>` : ''}
          ${i.message ? `<p class="muted ellipsis" style="margin:8px 0 0;font-size:12.5px">“${esc(i.message)}”</p>` : ''}</a>`;
      }).join('')}</div>` : empty('event_note', t('inq_empty'), t('inq_empty_sub'), t('start_exploring'), 'data-go="#/explore"')}</div>`;
  };

  /* ---------- Add property ---------- */
  let add = null;
  const newAdd = () => ({ step: 0, kind: 'resale', type: 'apartment', city: 'New Cairo', address: '', area: '', beds: 3, baths: 2, floor: 1, finish: 'full', ready: true, delivery: new Date().getFullYear() + 2, price: '', paid: '', years: 6, negotiable: true, photos: [], desc: '', name: state.user ? state.user.name : '', phone: state.user ? state.user.phone : '', agree: false });
  SCREENS.add = () => {
    if (!add) add = newAdd();
    const a = add;
    const titles = ['s1_title', 's2_title', 's3_title', 's4_title'];
    afterRender = () => {
      app.querySelectorAll('[data-bind]').forEach((el) => el.addEventListener('input', () => {
        let v = el.value; if (el.dataset.num) { v = v.replace(/\D/g, '').slice(0, +el.dataset.num); el.value = v; }
        a[el.dataset.bind] = v;
        const h = app.querySelector(`[data-helper="${el.dataset.bind}"]`); if (h) h.textContent = +v > 0 ? full(+v) : '';
      }));
    };
    const cityObj = DATA.cities.find((c) => c.en === a.city);
    let body = '';
    if (a.step === 0) {
      body = `<h2 class="h1" style="font-size:22px">${esc(t('s1_title'))}</h2>
        ${['resale', 'assignment'].map((k) => `<button class="kindopt mt16 ${a.kind === k ? 'on' : ''}" data-act="addSet" data-k="kind" data-v="${k}"><span class="ic">${icon(k === 'resale' ? 'sell' : 'swap_horiz')}</span><div class="grow"><b style="font-size:16px">${esc(kindLabel(k))}</b><div class="muted" style="font-size:12.5px">${esc(t(k === 'resale' ? 'resale_desc' : 'assignment_desc'))}</div></div>${icon(a.kind === k ? 'radio_button_checked' : 'radio_button_unchecked')}</button>`).join('')}
        <div class="field mt24"><label>${esc(t('property_type'))}</label><div class="typegrid">${TYPES.map((k) => `<button class="${a.type === k ? 'on' : ''}" data-act="addSet" data-k="type" data-v="${k}">${icon(TYPE_ICON[k])}<span>${esc(typeLabel(k))}</span></button>`).join('')}</div></div>`;
    } else if (a.step === 1) {
      body = `<div class="field"><label>${esc(t('city'))}</label><div class="row wrap gap8">${DATA.cities.map((c) => pill(c[state.lang], a.city === c.en, `data-act="addSet" data-k="city" data-v="${esc(c.en)}"`, '', true)).join('')}</div></div>
        <div class="field mt16"><label for="aaddr">${esc(t('compound_name'))}</label><div class="input">${icon('location_on')}<input id="aaddr" data-bind="address" placeholder="${esc(t('compound_hint'))}" value="${esc(a.address)}"></div></div>
        <div class="field mt12"><label for="aarea">${esc(t('area_sqm'))}</label><div class="input">${icon('square_foot')}<input id="aarea" data-bind="area" data-num="5" inputmode="numeric" placeholder="150" value="${esc(a.area)}"></div></div>
        <div class="mt16" style="display:grid;gap:10px">${counter(t('bedrooms'), a.beds, 0, 10, 'addBeds')}${counter(t('baths'), a.baths, 1, 10, 'addBaths')}${counter(t('floor'), a.floor, 0, 40, 'addFloor')}</div>
        <div class="field mt16"><label>${esc(t('finishing'))}</label><div class="row wrap gap8">${FINISHES.map((k) => pill(finishLabel(k), a.finish === k, `data-act="addSet" data-k="finish" data-v="${k}"`, '', true)).join('')}</div></div>
        <div class="field mt16"><label>${esc(t('status'))}</label>${seg([t('ready'), t('offplan')], a.ready ? 0 : 1, 'addReady')}</div>
        ${a.ready ? '' : `<div class="mt12">${counter(t('delivery_year'), a.delivery, new Date().getFullYear(), new Date().getFullYear() + 8, 'addDelivery')}</div>`}`;
    } else if (a.step === 2) {
      body = `<div class="field"><label for="aprice">${esc(t('price_egp'))}</label><div class="input">${icon('payments')}<input id="aprice" data-bind="price" data-num="10" inputmode="numeric" placeholder="5000000" value="${esc(a.price)}"></div><div class="helper" data-helper="price">${+a.price > 0 ? esc(full(+a.price)) : ''}</div></div>
        ${a.kind === 'assignment' ? `<div class="field mt12"><label for="apaid">${esc(t('paid_egp'))}</label><div class="input">${icon('account_balance_wallet')}<input id="apaid" data-bind="paid" data-num="10" inputmode="numeric" placeholder="800000" value="${esc(a.paid)}"></div><div class="helper" data-helper="paid">${+a.paid > 0 ? esc(full(+a.paid)) : ''}</div></div><div class="mt12">${counter(t('remaining_years'), a.years, 1, 12, 'addYears')}</div>` : ''}
        <div class="counter mt12"><b>${esc(t('negotiable'))}</b><button class="switch ${a.negotiable ? 'on' : ''}" style="width:50px;height:30px;border-radius:15px;background:${a.negotiable ? 'var(--forest)' : 'var(--line)'}" data-act="addNeg" aria-label="negotiable"></button></div>
        <div class="row between mt20"><label style="font-weight:800">${esc(t('photos'))}</label><b style="color:var(--gold-deep);font-size:12.5px">${a.photos.length}/8</b></div>
        <p class="muted" style="margin:2px 0 10px;font-size:12px">${esc(t('photos_hint'))}</p>
        <div class="photos">${samplePhotos.map((s, i) => `<button class="${a.photos.includes(i) ? 'on' : ''}" data-act="addPhoto" data-v="${i}">${im(s)}<span class="sel">${icon('check_circle')}</span></button>`).join('')}</div>
        <div class="field mt20"><label for="adesc">${esc(t('description'))}</label><div class="input"><textarea id="adesc" data-bind="desc" rows="4" placeholder="${esc(t('desc_hint'))}">${esc(a.desc)}</textarea></div></div>`;
    } else {
      const cover = a.photos.length ? samplePhotos[[...a.photos].sort((x, y) => x - y)[0]] : null;
      const row = (k, v) => `<div class="inforow"><span>${esc(k)}</span><b>${esc(v)}</b></div>`;
      body = `<div class="card" style="overflow:hidden">${cover ? im(cover, '', 'height:160px') : ''}<div style="padding:16px"><div class="row gap8">${tag(kindLabel(a.kind))}${tag(t('pending_review'), 'gold')}</div>
          <div class="price mt12" style="font-size:20px">${+a.price ? esc(full(+a.price)) : '—'}</div><div class="h3">${esc(typeLabel(a.type))} • ${esc(cityObj[state.lang])}</div>
          <div class="mt12">${row(t('compound_name'), a.address || '—')}${row(t('area'), `${a.area} ${t('sqm')}`)}${row(`${t('beds')} / ${t('baths')}`, `${a.beds} / ${a.baths}`)}${row(t('finishing'), finishLabel(a.finish))}${row(t('delivery'), a.ready ? t('ready_now') : a.delivery)}${a.kind === 'assignment' ? row(t('paid_amount'), full(+a.paid || 0)) : ''}${row(t('photos'), a.photos.length)}</div></div></div>
        <div class="field mt20"><label>${esc(t('contact_info'))}</label><div class="input">${icon('person')}<input data-bind="name" placeholder="${esc(t('full_name'))}" value="${esc(a.name)}"></div></div>
        <div class="input ltr mt12">${icon('phone_iphone')}<input data-bind="phone" data-num="11" inputmode="numeric" placeholder="01XXXXXXXXX" value="${esc(a.phone)}"></div>
        <button class="check mt16 ${a.agree ? 'on' : ''}" data-act="addAgree"><span class="box">${icon('check')}</span><span style="text-align:start">${esc(t('agree_terms'))}</span></button>`;
    }
    const last = a.step === 3;
    return `<div class="withbar"><div class="topbar"><button class="cbtn" data-act="addBack" aria-label="back">${icon('arrow_back', 'flip')}</button><span class="title">${esc(t('add_title'))}</span><span class="spacer"></span></div>
      <div class="pad"><div class="row between" style="margin-bottom:10px"><b style="color:var(--gold-deep);font-size:12.5px">${esc(t('step'))} ${a.step + 1} ${esc(t('of'))} 4</b><b style="font-size:13px">${esc(t(titles[a.step]))}</b></div>
        <div class="steps">${[0, 1, 2, 3].map((i) => `<i class="${i <= a.step ? 'on' : ''}"></i>`).join('')}</div>
        <div class="mt20" style="animation:fadeUp .35s both" key="${a.step}">${body}</div></div>
      <div class="bottombar">${a.step ? `<button class="btn btn-outline" style="flex:2" data-act="addBack">${esc(t('back'))}</button>` : ''}
        <button class="btn ${last ? 'btn-gold' : 'btn-forest'}" style="flex:3" data-act="addNext">${esc(t(last ? 'publish' : 'next'))}${icon(last ? 'publish' : 'arrow_forward', last ? '' : 'flip')}</button></div></div>`;
  };
  function addValidate() {
    const a = add;
    if (a.step === 1 && (a.address.trim().length < 3 || +a.area < 20)) return t('err_complete_step');
    if (a.step === 2) { if (+a.price < 100000) return t('err_complete_step'); if (a.kind === 'assignment' && !(+a.paid > 0)) return t('err_complete_step'); if (!a.photos.length) return t('err_photos'); }
    if (a.step === 3) { if (a.name.trim().length < 2) return t('err_name'); if (!isMobile(a.phone)) return t('err_phone'); if (!a.agree) return t('err_terms'); }
    return null;
  }
  function addPublish() {
    const a = add; const c = DATA.cities.find((x) => x.en === a.city); const pos = DATA.cityPos[a.city] || [0.5, 0.5];
    const b = app.querySelector('[data-act="addNext"]'); b.innerHTML = '<span class="spinner"></span>'; b.disabled = true;
    setTimeout(() => {
      const paid = a.kind === 'assignment' ? +a.paid : null;
      state.myListings.unshift({
        id: 'u' + Date.now(), title: { ar: `${STR['type_' + a.type][0]} ${STR['kind_' + a.kind][0]} - ${c.ar}`, en: `${STR['type_' + a.type][1]} ${STR['kind_' + a.kind][1]} - ${c.en}` },
        type: a.type, kind: a.kind, price: +a.price, area: +a.area, beds: a.beds, baths: a.baths, floor: a.floor,
        location: { ar: a.address.trim(), en: a.address.trim() }, city: c, images: [...a.photos].sort((x, y) => x - y).map((i) => samplePhotos[i].replace('w=600', 'w=1200')),
        description: a.desc.trim() ? { ar: a.desc.trim(), en: a.desc.trim() } : { ar: `${a.address.trim()} — ${a.area} م²`, en: `${a.address.trim()} — ${a.area} m²` },
        amenities: [], finish: a.finish, deliveryYear: a.ready ? new Date().getFullYear() : a.delivery, isReady: a.ready, x: pos[0], y: pos[1],
        verified: false, listedAt: Date.now(), paidAmount: paid, downPayment: paid, installmentYears: a.kind === 'assignment' ? a.years : null,
        sellerName: a.name.trim(), negotiable: a.negotiable, pendingReview: true,
      });
      persist(); add = null;
      success(t('listing_sent'), t('listing_sent_sub'), t('view_listings'), t('done'), (ok) => { if (ok) go('#/listings', true); else goBack(); });
    }, 1000);
  }

  SCREENS.listings = () => `<div><div class="topbar">${back()}<span class="title">${esc(t('my_listings'))}</span><a class="cbtn" href="#/add" style="box-shadow:none">${icon('add_circle')}</a></div>
    ${state.myListings.length ? `<div class="pad stagger" style="display:grid;gap:16px;padding-top:8px">${state.myListings.map((p) => propertyCard(p)).join('')}</div>` : empty('add_home_work', t('listings_empty'), t('listings_empty_sub'), t('sell_your_unit'), 'data-go="#/add"')}</div>`;

  /* ---------- Profile ---------- */
  SCREENS.profile = () => {
    const u = state.user;
    const item = (ic, label, attrs, trailing) => `<${trailing ? 'div' : 'button'} class="item" ${attrs || ''}><span class="ic">${icon(ic)}</span><b>${esc(label)}</b>${trailing || icon('chevron_right', 'flip muted')}</${trailing ? 'div' : 'button'}>`;
    const group = (title, items) => `<div class="group mt20"><h4>${esc(title)}</h4><div class="card">${items.join('')}</div></div>`;
    return `<div><header class="prof-hero"><div class="row">${back(true)}<span class="grow" style="font-weight:800;font-size:17px">${esc(t('profile'))}</span><span style="width:44px"></span></div>
        <div class="bigav">${u ? esc(u.name.trim().charAt(0).toUpperCase() || 'D') : icon('person', 'fill')}</div>
        <h1 class="h1 mt12" style="font-size:20px">${u ? esc(u.name) : esc(t('guest_user'))}</h1>
        ${u ? `<b class="ltr" style="color:var(--gold);font-size:13.5px">+20 ${esc(u.phone)}</b>` : `<p style="margin:2px 0 14px;font-size:13px;color:rgba(255,255,255,.75)">${esc(t('guest_sub'))}</p><a class="btn btn-gold inline sm" style="display:inline-flex" href="#/login?from=profile">${icon('login')}${esc(t('sign_in'))}</a>`}
        <div class="pstats"><button data-go="#/favorites"><b>${state.fav.length}</b><span>${esc(t('saved'))}</span></button><button data-go="#/inquiries"><b>${state.inquiries.length}</b><span>${esc(t('requests'))}</span></button><button data-go="#/listings"><b>${state.myListings.length}</b><span>${esc(t('listings'))}</span></button><button data-go="#/compare"><b>${state.compare.length}</b><span>${esc(t('tool_compare'))}</span></button></div></header>
      <div class="pad" style="padding-bottom:30px">
        ${group(t('account'), [item('event_note', t('my_inquiries'), 'data-go="#/inquiries"'), item('home_work', t('my_listings'), 'data-go="#/listings"'), item('add_home_work', t('add_title'), 'data-go="#/add"')])}
        ${group(t('preferences'), [item('translate', t('language'), '', `<div style="width:150px">${seg(['العربية', 'English'], ar() ? 0 : 1, 'setLang')}</div>`), item('notifications', t('notifications'), '', `<button class="switch ${state.notificationsOn ? 'on' : ''}" data-act="notifToggle" aria-label="notifications"></button>`)])}
        ${group(t('tools'), [item('compare_arrows', t('compare_title'), 'data-go="#/compare"'), item('map', t('map_title'), 'data-go="#/map"'), item('location_city', t('all_projects'), 'data-go="#/projects"')])}
        ${group(t('support'), [item('support_agent', t('contact_us'), 'data-go="#/inquiry?type=info"'), item('info', t('about_app'), 'data-act="about"')])}
        ${u ? `<div class="mt20"><button class="btn btn-outline" data-act="logout">${icon('logout', 'flip')}${esc(t('logout'))}</button></div>` : ''}
        <p class="muted" style="text-align:center;font-size:11.5px;margin-top:18px">DAMSTOCK HOMES • ${esc(t('version'))} 1.0.0</p></div></div>`;
  };

  function notFound() { return `<div><div class="topbar">${back()}</div>${empty('home_work', t('no_results'), '')}</div>`; }

  /* =========================================================
     Overlays
     ========================================================= */
  let toastT = null;
  function toast(msg, kind, action) {
    const el = document.getElementById('toast');
    el.innerHTML = `${icon(kind === 'error' ? 'error' : kind === 'info' ? 'info' : 'check_circle')}<span>${esc(msg)}</span>${action ? `<button class="act">${esc(action.label)}</button>` : ''}`;
    if (action) el.querySelector('.act').onclick = () => { el.classList.remove('show'); action.fn(); };
    el.classList.add('show'); clearTimeout(toastT); toastT = setTimeout(() => el.classList.remove('show'), 2200);
  }
  function openSheet(html) {
    layer.innerHTML = `<div class="overlay"><div class="bsheet">${html}</div></div>`;
    const ov = layer.firstElementChild;
    ov.addEventListener('click', (e) => { if (e.target === ov) closeLayer(); });
    document.body.style.overflow = 'hidden';
    return ov.firstElementChild;
  }
  function closeLayer() { layer.innerHTML = ''; document.body.style.overflow = ''; }
  function success(title, body, primary, secondary, cb) {
    layer.innerHTML = `<div class="overlay center"><div class="dialog"><div class="ok">${icon('check')}</div><h3>${esc(title)}</h3><p>${esc(body)}</p><button class="btn btn-gold" data-r="1">${esc(primary)}</button><button class="btn btn-outline mt12" data-r="0">${esc(secondary)}</button></div></div>`;
    layer.querySelectorAll('[data-r]').forEach((b) => (b.onclick = () => { closeLayer(); cb(b.dataset.r === '1'); }));
  }

  /* =========================================================
     Actions (event delegation)
     ========================================================= */
  const ACT = {
    back: () => goBack(),
    lang: () => { state.lang = ar() ? 'en' : 'ar'; persist(); rerender(); },
    setLang: (b) => { const l = b.dataset.i === '0' ? 'ar' : 'en'; if (l !== state.lang) { state.lang = l; persist(); rerender(); } },
    obNext: () => { if (obIndex < OB.length - 1) { obIndex++; rerender(); } else ACT.obFinish(); },
    obFinish: () => { state.onboarded = true; persist(); go('#/login', true); },
    loginGo: () => {
      auth.err = { name: auth.name.trim().length < 2, phone: !isMobile(auth.phone) };
      if (auth.err.name || auth.err.phone) return rerender();
      auth.code = ''; auth.otpErr = false; auth.timer = 30; go('#/otp');
    },
    guest: () => { if (auth.from) goBack(); else { historyDepth = 0; go('#/home', true); } },
    verify: () => verify(),
    resend: () => { auth.timer = 30; rerender(); },
    fav: (b) => { const id = b.dataset.id; state.fav = state.fav.includes(id) ? state.fav.filter((x) => x !== id) : [...state.fav, id]; persist(); if (navigator.vibrate) navigator.vibrate(15); rerender(); },
    compare: (b) => {
      const id = b.dataset.id;
      if (state.compare.includes(id)) { state.compare = state.compare.filter((x) => x !== id); persist(); rerender(); if (current.name !== 'compare') toast(t('compare_removed'), 'info'); return; }
      if (state.compare.length >= 3) return toast(t('compare_full'), 'info');
      state.compare.push(id); persist(); rerender(); toast(t('compare_added'), '', { label: t('view'), fn: () => go('#/compare') });
    },
    clearCompare: () => { state.compare = []; persist(); rerender(); },
    compareFavs: () => { state.compare = state.fav.slice(0, 3); persist(); go('#/compare'); },
    notifs: () => openSheet(`<div class="grab"></div><div class="scroll"><h2 class="h2" style="font-size:19px;margin-bottom:12px">${esc(t('notifications'))}</h2>${notifications.map((n) => `<div class="card row" style="padding:14px;margin-bottom:10px"><span style="width:42px;height:42px;border-radius:14px;background:var(--forest);color:var(--gold);display:grid;place-items:center;flex:none">${icon(n.icon)}</span><div class="grow"><b>${esc(n.t[ar() ? 0 : 1])}</b><div class="muted" style="font-size:12.5px">${esc(n.b[ar() ? 0 : 1])}</div></div><small class="muted">${esc(ago(n.at))}</small></div>`).join('')}</div>`),
    calc: () => { const s = openSheet(`<div class="grab"></div><div class="scroll">${calculator('home', 6000000, 10, 8, true)}</div>`); bindCalc(s); },
    exploreType: (b) => { state.filter = Object.assign(defaultFilter(), { types: [b.dataset.v] }); go('#/explore'); },
    exploreCity: (b) => { state.filter = Object.assign(defaultFilter(), { city: b.dataset.v }); go('#/explore'); },
    kind: (b) => { state.filter.kind = b.dataset.v || null; rerender(); },
    filters: () => filterSheet(),
    clearFilters: () => { state.filter = defaultFilter(); rerender(); },
    sortMenu: (b) => sortMenu(b),
    sort: (b) => { state.filter.sort = b.dataset.v; rerender(); },
    devSeg: (b) => { devSeg = +b.dataset.i; rerender(); },
    projStatus: (b) => { projStatus = b.dataset.v; rerender(); },
    resaleSeg: (b) => { resaleSeg = +b.dataset.i; rerender(); },
    resaleInfo: () => { resaleInfo = !resaleInfo; rerender(); },
    mapKind: (b) => { mapKind = b.dataset.v; mapSel = null; rerender(); },
    pin: (b) => { mapSel = b.dataset.id; if (navigator.vibrate) navigator.vibrate(10); rerender(); },
    share: () => { const url = location.href; if (navigator.clipboard) navigator.clipboard.writeText(url).catch(() => {}); toast(t('shared')); },
    call: () => toast(t('calling'), 'info'),
    whatsapp: () => toast(t('opening_whatsapp'), 'info'),
    fullgal: (b) => { const r = parseHash(); const src = r.name === 'property' ? propById(r.params[0]) : projById(r.params[0]); if (src) fullGallery(src.images, +b.dataset.i); },
    inqType: (b) => { inq.type = ['info', 'viewing', 'callback'][+b.dataset.i]; rerender(); },
    inqDay: (b) => { inq.day = +b.dataset.v; rerender(); },
    inqSlot: (b) => { inq.slot = b.dataset.v; rerender(); },
    inqWa: (b) => { inq.wa = b.dataset.v === '1'; rerender(); },
    inqSubmit: () => submitInquiry(),
    inqSeg: (b) => go(`#/inquiries?s=${b.dataset.i}`, true),
    addSet: (b) => { add[b.dataset.k] = b.dataset.v; rerender(); },
    addBeds: (b) => { add.beds += +b.dataset.d; rerender(); },
    addBaths: (b) => { add.baths += +b.dataset.d; rerender(); },
    addFloor: (b) => { add.floor += +b.dataset.d; rerender(); },
    addDelivery: (b) => { add.delivery += +b.dataset.d; rerender(); },
    addYears: (b) => { add.years += +b.dataset.d; rerender(); },
    addReady: (b) => { add.ready = b.dataset.i === '0'; rerender(); },
    addNeg: () => { add.negotiable = !add.negotiable; rerender(); },
    addPhoto: (b) => { const i = +b.dataset.v; add.photos = add.photos.includes(i) ? add.photos.filter((x) => x !== i) : [...add.photos, i]; rerender(); },
    addAgree: () => { add.agree = !add.agree; rerender(); },
    addNext: () => { const err = addValidate(); if (err) { if (navigator.vibrate) navigator.vibrate(60); return toast(err, 'error'); } if (add.step === 3) return addPublish(); add.step++; route(); },
    addBack: () => { if (add.step === 0) { add = null; goBack(); } else { add.step--; route(); } },
    notifToggle: () => { state.notificationsOn = !state.notificationsOn; persist(); rerender(); },
    about: () => openSheet(`<div class="grab"></div><div class="scroll" style="text-align:center"><div style="display:inline-grid;padding:16px;border-radius:24px;background:var(--forest-dark)">${brandMark(60)}</div><div class="mt12">${wordmark(22, '#102C27')}</div><p style="color:var(--gold-deep);font-weight:700;margin:6px 0 0">${esc(t('tagline'))}</p><p class="para">${esc(t('about_app_body'))}</p><button class="btn btn-outline mt16" data-close-sheet="1">${esc(t('close'))}</button></div>`),
    logout: () => { state.user = null; persist(); toast(t('logged_out'), 'info'); rerender(); },
  };

  document.addEventListener('click', (e) => {
    if (e.target.closest('[data-close-sheet]')) return closeLayer();
    if (layer.contains(e.target) && !e.target.closest('#layer [data-act]')) return;
    const menu = app.querySelector('.sortmenu');
    if (menu && !e.target.closest('.sortmenu,[data-act="sortMenu"]')) menu.remove();
    const a = e.target.closest('[data-act]');
    if (a && ACT[a.dataset.act]) {
      e.preventDefault(); e.stopPropagation();
      if (layer.contains(a)) closeLayer();
      ACT[a.dataset.act](a); return;
    }
    const g = e.target.closest('[data-go]');
    if (g) { e.preventDefault(); go(g.dataset.go, !!g.dataset.replace); return; }
    const link = e.target.closest('a[href^="#/"]');
    if (link) { e.preventDefault(); go(link.getAttribute('href')); }
  });

  function bindCalc(root) {
    root.addEventListener('input', (e) => {
      const f = e.target.dataset.calcf; if (!f) return;
      const box = e.target.closest('[data-calc]'); const c = calcState[box.dataset.calc];
      c[f] = +e.target.value;
      const editable = !!e.target.dataset.editable;
      box.innerHTML = calcInner(c, editable);
      const again = box.querySelector(`[data-calcf="${f}"]`); if (again) again.focus();
    });
  }
  bindCalc(app);

  window.addEventListener('keydown', (e) => { if (e.key === 'Escape') closeLayer(); });

  route();
})();
