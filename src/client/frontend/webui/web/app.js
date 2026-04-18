const root = document.querySelector('#app');

const state = {
  authTab: 'login',
  authenticated: false,
  currentPage: 'overview',
  focusId: '',
  rightCollapsed: false,
  query: '',
  mode: 'sync',
  connection: 'boot',
  notice: 'warm',
  recovery: 'passphrase',
  snapshot: normalizeSnapshot(buildLocalSnapshot())
};

window.addEventListener('load', boot);

async function boot() {
  if (!root) {
    return;
  }
  document.addEventListener('click', onClick);
  document.addEventListener('input', onInput);
  document.addEventListener('submit', onSubmit);
  attachBridgeEvents();
  syncCurrentPage();
  ensureFocus(true);
  render();
  await hydrateSnapshot(false);
}

function attachBridgeEvents() {
  if (!window.webui || typeof window.webui.setEventCallback !== 'function' || !window.webui.event) {
    return;
  }
  window.webui.setEventCallback((eventCode) => {
    if (eventCode === window.webui.event.CONNECTED) {
      state.connection = 'live';
      state.notice = 'bridge';
      render();
      hydrateSnapshot(true);
      return;
    }
    if (eventCode === window.webui.event.DISCONNECTED) {
      state.connection = 'hold';
      state.notice = 'link';
      render();
    }
  });
}

function onClick(event) {
  const target = event.target instanceof Element ? event.target : null;
  if (!target) {
    return;
  }

  const authTabButton = target.closest('[data-auth-tab]');
  if (authTabButton) {
    state.authTab = authTabButton.dataset.authTab || 'login';
    state.notice = state.authTab;
    render();
    return;
  }

  const recoveryButton = target.closest('[data-recovery]');
  if (recoveryButton) {
    state.recovery = recoveryButton.dataset.recovery || 'passphrase';
    state.notice = state.recovery;
    render();
    return;
  }

  const navButton = target.closest('[data-nav]');
  if (navButton) {
    state.currentPage = navButton.dataset.nav || state.currentPage;
    state.notice = state.currentPage;
    ensureFocus(true);
    render();
    return;
  }

  const focusButton = target.closest('[data-focus]');
  if (focusButton) {
    state.focusId = focusButton.dataset.focus || state.focusId;
    state.notice = 'focus';
    render();
    return;
  }

  const toggleButton = target.closest('[data-toggle-panel]');
  if (toggleButton) {
    state.rightCollapsed = !state.rightCollapsed;
    state.notice = state.rightCollapsed ? 'fold' : 'open';
    render();
    return;
  }

  const modeButton = target.closest('[data-mode]');
  if (modeButton) {
    state.mode = modeButton.dataset.mode || state.mode;
    state.notice = state.mode;
    render();
    return;
  }

  const refreshButton = target.closest('[data-refresh]');
  if (refreshButton) {
    hydrateSnapshot(true);
  }
}

function onInput(event) {
  const target = event.target instanceof Element ? event.target : null;
  if (!target) {
    return;
  }
  if (target.matches('[data-query]')) {
    state.query = target.value;
    render();
    return;
  }
  if (target.matches('.picker-input')) {
    state.notice = 'avatar';
    render();
  }
}

function onSubmit(event) {
  const target = event.target instanceof Element ? event.target : null;
  if (!target) {
    return;
  }
  const form = target.closest('[data-auth-form]');
  if (!form) {
    return;
  }
  event.preventDefault();
  state.authenticated = true;
  state.notice = state.authTab;
  syncCurrentPage();
  ensureFocus(true);
  render();
}

async function hydrateSnapshot(isManual) {
  state.connection = isManual ? 'sync' : state.connection;
  state.notice = isManual ? 'fetch' : state.notice;
  render();

  try {
    const raw = await requestSnapshotText();
    const parsed = parseSnapshot(raw);
    state.snapshot = normalizeSnapshot(parsed);
    state.connection = 'live';
    state.notice = 'fresh';
  } catch (error) {
    state.snapshot = normalizeSnapshot(buildLocalSnapshot(error));
    state.connection = 'local';
    state.notice = 'cache';
  }

  syncCurrentPage();
  ensureFocus(true);
  render();
}

async function requestSnapshotText() {
  let lastError = new Error('protoGetSnapshot bridge unavailable');
  let tries = 0;

  while (tries < 12) {
    tries += 1;
    for (const request of bridgeRequests()) {
      try {
        const value = await request();
        if (typeof value === 'string' && value.trim()) {
          return value;
        }
        if (value && typeof value === 'object') {
          return JSON.stringify(value);
        }
      } catch (error) {
        lastError = error instanceof Error ? error : new Error(String(error));
      }
    }
    await delay(180);
  }

  throw lastError;
}

function bridgeRequests() {
  return [
    async () => {
      if (typeof window.protoGetSnapshot === 'function') {
        return window.protoGetSnapshot();
      }
      return '';
    },
    async () => {
      if (window.webui && typeof window.webui.protoGetSnapshot === 'function') {
        return window.webui.protoGetSnapshot();
      }
      return '';
    },
    async () => {
      if (window.webui && typeof window.webui.call === 'function') {
        return window.webui.call('protoGetSnapshot');
      }
      return '';
    }
  ];
}

function delay(ms) {
  return new Promise((resolve) => window.setTimeout(resolve, ms));
}

function parseSnapshot(raw) {
  if (!raw) {
    return {};
  }
  if (typeof raw === 'object') {
    return raw;
  }
  if (typeof raw !== 'string') {
    return { raw: String(raw) };
  }
  try {
    return JSON.parse(raw);
  } catch (error) {
    return { raw };
  }
}

function normalizeSnapshot(source) {
  const payload = source && typeof source === 'object' ? source : {};
  const pages = Array.isArray(payload.pages) && payload.pages.length
    ? payload.pages.map((page, index) => normalizePage(page, index))
    : buildPagesFromSource(payload);
  const focus = Array.isArray(payload.focus) && payload.focus.length
    ? payload.focus.slice(0, 4).map((item, index) => normalizeItem(item, index, 'focus'))
    : pages.flatMap((page) => page.items.slice(0, 2)).slice(0, 4);
  const statusLine = Array.isArray(payload.statusLine) && payload.statusLine.length
    ? payload.statusLine.slice(0, 5).map((item, index) => normalizeStatusChip(item, index))
    : buildStatusLine(payload, pages);

  return {
    title: stringValue(firstDefined(payload.appName, payload.name, payload.title, 'proto conventions')),
    summary: stringValue(firstDefined(payload.summary, payload.description, payload.status, 'snapshot')),
    pages,
    focus,
    statusLine
  };
}

function normalizePage(page, index) {
  const label = stringValue(firstDefined(page.label, page.name, page.id, `Page ${index + 1}`));
  const itemsSource = Array.isArray(page.items)
    ? page.items
    : buildItemsFromValue(label.toLowerCase(), firstDefined(page.data, page.values, page));
  const items = itemsSource.map((item, itemIndex) => normalizeItem(item, itemIndex, label));

  return {
    id: slug(firstDefined(page.id, label, `page-${index + 1}`)),
    label,
    caption: stringValue(firstDefined(page.caption, page.summary, page.kind, `${items.length} lanes`)),
    items
  };
}

function normalizeItem(input, index, scope) {
  if (input && typeof input === 'object' && !Array.isArray(input)) {
    const label = stringValue(firstDefined(input.label, input.name, input.key, `${scope}-${index + 1}`));
    const value = stringValue(firstDefined(input.value, input.status, input.summary, input.count, input.total, input.note, input.id, '--'));
    const meta = stringValue(firstDefined(input.meta, input.caption, input.kind, input.state, ''));
    const tone = stringValue(firstDefined(input.tone, input.kind, pickTone(label, index)));
    const detail = buildDetail(firstDefined(input.detail, input.details, input.data, input.fields, input));
    return {
      id: slug(`${scope}-${label}-${index}`),
      label,
      value,
      meta,
      tone,
      detail
    };
  }

  return {
    id: slug(`${scope}-${index}`),
    label: stringValue(scope),
    value: stringValue(input),
    meta: '',
    tone: pickTone(scope, index),
    detail: buildDetail(input)
  };
}

function normalizeStatusChip(input, index) {
  if (input && typeof input === 'object' && !Array.isArray(input)) {
    return {
      label: stringValue(firstDefined(input.label, input.name, `s${index + 1}`)),
      value: stringValue(firstDefined(input.value, input.status, input.meta, '--')),
      tone: stringValue(firstDefined(input.tone, pickTone(`status-${index}`, index)))
    };
  }
  return {
    label: `s${index + 1}`,
    value: stringValue(input),
    tone: pickTone(`status-${index}`, index)
  };
}

function buildPagesFromSource(source) {
  const entries = Object.entries(source).filter(([key]) => !['pages', 'focus', 'statusLine'].includes(key));
  const primitives = entries.filter(([, value]) => !isStructured(value));
  const structures = entries.filter(([, value]) => isStructured(value));

  const overviewItems = primitives.slice(0, 8).map(([key, value], index) => normalizeItem({
    label: key,
    value,
    meta: describeValue(value)
  }, index, 'overview'));

  const signalItems = structures.flatMap(([key, value]) => buildItemsFromValue(key, value)).slice(0, 10);
  const payloadItems = entries.slice(0, 8).map(([key, value], index) => normalizeItem({
    label: key,
    value: previewValue(value),
    meta: describeValue(value)
  }, index, 'payload'));

  const pages = [
    { id: 'overview', label: 'Overview', caption: 'core', items: overviewItems },
    { id: 'signals', label: 'Signals', caption: 'shape', items: signalItems },
    { id: 'payload', label: 'Payload', caption: 'raw', items: payloadItems }
  ].filter((page) => page.items.length > 0);

  if (pages.length > 0) {
    return pages.map((page, index) => normalizePage(page, index));
  }

  return buildLocalSnapshot().pages.map((page, index) => normalizePage(page, index));
}

function buildItemsFromValue(key, value) {
  if (Array.isArray(value)) {
    if (!value.length) {
      return [normalizeItem({ label: key, value: '0 set', meta: 'empty' }, 0, key)];
    }
    return value.slice(0, 8).map((entry, index) => normalizeItem(
      typeof entry === 'object' && entry !== null
        ? { ...entry, meta: firstDefined(entry.meta, key) }
        : { label: `${key}-${index + 1}`, value: entry, meta: key },
      index,
      key
    ));
  }

  if (value && typeof value === 'object') {
    return Object.entries(value).slice(0, 8).map(([subKey, subValue], index) => normalizeItem({
      label: subKey,
      value: subValue,
      meta: key
    }, index, key));
  }

  return [normalizeItem({ label: key, value, meta: 'state' }, 0, key)];
}

function buildStatusLine(source, pages) {
  return [
    { label: 'app', value: stringValue(firstDefined(source.appName, source.name, 'proto')), tone: 'active' },
    { label: 'state', value: stringValue(firstDefined(source.status, source.state, 'ready')), tone: 'glue' },
    { label: 'pages', value: String(pages.length), tone: 'tiny' }
  ];
}

function buildDetail(value) {
  const skip = new Set(['label', 'value', 'meta', 'tone', 'caption', 'kind', 'id', 'name', 'key', 'items']);

  if (Array.isArray(value)) {
    return value.slice(0, 6).map((entry, index) => ({
      label: `${index + 1}`,
      value: stringValue(entry)
    }));
  }

  if (value && typeof value === 'object') {
    return Object.entries(value)
      .filter(([key]) => !skip.has(key))
      .slice(0, 8)
      .map(([key, entry]) => ({
        label: key,
        value: stringValue(entry)
      }));
  }

  if (stringValue(value)) {
    return [{ label: 'value', value: stringValue(value) }];
  }

  return [];
}

function buildLocalSnapshot(error) {
  const stamp = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  const note = error instanceof Error ? trimText(error.message, 52) : 'bridge warm';

  return {
    appName: 'proto conventions',
    status: error ? 'fallback' : 'ready',
    summary: error ? 'local mirror' : 'nim-webui',
    pages: [
      {
        id: 'overview',
        label: 'Overview',
        caption: 'core',
        items: [
          { label: 'gate', value: error ? 'local' : 'bridge', meta: 'link', tone: 'active' },
          { label: 'mode', value: 'nim-webui', meta: 'shell', tone: 'tiny' },
          { label: 'state', value: error ? 'cached' : 'live', meta: 'status', tone: 'glue' }
        ]
      },
      {
        id: 'flow',
        label: 'Flow',
        caption: 'lane',
        items: [
          { label: 'auth', value: 'tab grid', meta: 'entry', tone: 'recommendation' },
          { label: 'main', value: 'split focus', meta: 'shell', tone: 'active' },
          { label: 'tail', value: 'status strip', meta: 'trace', tone: 'tiny' }
        ]
      },
      {
        id: 'pulse',
        label: 'Pulse',
        caption: 'tail',
        items: [
          { label: 'stamp', value: stamp, meta: 'clock', tone: 'glue' },
          { label: 'hint', value: note, meta: 'bridge', tone: 'recommendation' },
          { label: 'query', value: 'slice', meta: 'top menu', tone: 'active' }
        ]
      }
    ],
    focus: [
      { label: 'focus', value: 'right rail', meta: 'collapse', tone: 'active' },
      { label: 'sync', value: note, meta: 'bridge', tone: 'recommendation' }
    ],
    statusLine: [
      { label: 'stamp', value: stamp, tone: 'tiny' },
      { label: 'link', value: error ? 'local' : 'bridge', tone: 'active' },
      { label: 'mode', value: 'nim-webui', tone: 'glue' }
    ]
  };
}

function syncCurrentPage() {
  if (!state.snapshot.pages.length) {
    state.currentPage = 'overview';
    return;
  }
  if (!state.snapshot.pages.some((page) => page.id === state.currentPage)) {
    state.currentPage = state.snapshot.pages[0].id;
  }
}

function ensureFocus(force) {
  const page = getCurrentPage();
  if (!page) {
    state.focusId = '';
    return;
  }
  const hasFocus = page.items.some((item) => item.id === state.focusId);
  if (hasFocus && !force) {
    return;
  }
  state.focusId = page.items[0] ? page.items[0].id : '';
}

function getCurrentPage() {
  return state.snapshot.pages.find((page) => page.id === state.currentPage) || state.snapshot.pages[0] || null;
}

function getVisibleItems(page) {
  if (!page) {
    return [];
  }
  const query = state.query.trim().toLowerCase();
  if (!query) {
    return page.items;
  }
  return page.items.filter((item) => {
    const haystack = [
      item.label,
      item.value,
      item.meta,
      ...item.detail.map((detail) => `${detail.label} ${detail.value}`)
    ].join(' ').toLowerCase();
    return haystack.includes(query);
  });
}

function getCurrentFocus(page) {
  const source = page ? page.items : [];
  return source.find((item) => item.id === state.focusId)
    || state.snapshot.focus.find((item) => item.id === state.focusId)
    || source[0]
    || state.snapshot.focus[0]
    || null;
}

function render() {
  if (!root) {
    return;
  }
  root.innerHTML = state.authenticated ? renderDashboard() : renderAuth();
}

function renderAuth() {
  const authNote = state.authTab === 'recover' ? state.recovery : state.authTab;
  return `
    <main class="auth-shell">
      <section class="shell-panel auth-panel">
        <div class="tab-strip" role="tablist" aria-label="auth">
          ${renderAuthTabs()}
        </div>
        <div class="auth-stage">
          ${renderAuthStage()}
        </div>
        <div class="auth-status">
          ${renderMiniChip('link', state.connection, 'active')}
          ${renderMiniChip('note', authNote, 'glue')}
          ${renderMiniChip('mode', state.mode, 'tiny')}
        </div>
      </section>
    </main>
  `;
}

function renderAuthTabs() {
  return ['login', 'register', 'recover'].map((tab) => `
    <button
      type="button"
      class="tab-btn ${state.authTab === tab ? 'active' : ''}"
      data-auth-tab="${tab}"
      title="${tab}"
    >${tab}</button>
  `).join('');
}

function renderAuthStage() {
  if (state.authTab === 'register') {
    return `
      <form class="auth-form" data-auth-form>
        <label class="picker-slot" title="pick profile">
          <input class="picker-input" type="file" accept="image/*" />
          <span class="picker-mark">pick</span>
        </label>
        <input class="field" type="text" placeholder="handle" autocomplete="username" />
        <input class="field" type="email" placeholder="mail" autocomplete="email" />
        <input class="field" type="password" placeholder="key" autocomplete="new-password" />
        <div class="auth-menu">
          <button type="button" class="ghost-btn" data-auth-tab="login">back</button>
          <button type="submit" class="primary-btn">create</button>
        </div>
      </form>
    `;
  }

  if (state.authTab === 'recover') {
    return `
      <form class="auth-form" data-auth-form>
        <div class="recovery-grid">
          ${['passphrase', 'mail', 'sms'].map((method) => `
            <button
              type="button"
              class="recovery-btn ${state.recovery === method ? 'active' : ''}"
              data-recovery="${method}"
              title="${method}"
            >${method}</button>
          `).join('')}
        </div>
        <input class="field" type="text" placeholder="${state.recovery}" autocomplete="one-time-code" />
        <input class="field" type="password" placeholder="seal" autocomplete="new-password" />
        <div class="auth-menu">
          <button type="button" class="ghost-btn" data-auth-tab="login">back</button>
          <button type="submit" class="primary-btn">unlock</button>
        </div>
      </form>
    `;
  }

  return `
    <form class="auth-form" data-auth-form>
      <div class="profile-pod" title="profile slot">
        ${renderBadge('p', 'active', 1)}
      </div>
      <input class="field" type="text" placeholder="handle" autocomplete="username" />
      <input class="field" type="password" placeholder="key" autocomplete="current-password" />
      <div class="auth-menu">
        <button type="button" class="ghost-btn" data-auth-tab="recover">recover</button>
        <button type="submit" class="primary-btn">enter</button>
      </div>
    </form>
  `;
}

function renderDashboard() {
  const page = getCurrentPage();
  const items = getVisibleItems(page);
  const focus = getCurrentFocus(page);
  const statusChips = buildUiStatus(page, items);

  return `
    <main class="dashboard ${state.rightCollapsed ? 'is-collapsed' : ''}">
      <header class="shell-panel top-menu">
        <div class="search-slot">
          <input
            class="search-field"
            data-query
            type="search"
            value="${escapeHtml(state.query)}"
            placeholder="slice"
            aria-label="slice"
          />
        </div>
        <nav class="nav-strip" aria-label="pages">
          ${state.snapshot.pages.map((entry) => `
            <button
              type="button"
              class="nav-btn ${page && page.id === entry.id ? 'active' : ''}"
              data-nav="${entry.id}"
              title="${entry.label}"
            >${entry.label}</button>
          `).join('')}
        </nav>
        <div class="view-strip">
          ${renderMiniChip('app', state.snapshot.title, 'active')}
          ${renderMiniChip('page', page ? page.caption : 'lane', 'glue')}
          ${renderMiniChip('set', String(items.length), 'tiny')}
        </div>
        <div class="action-strip">
          <button type="button" class="mode-btn ${state.mode === 'sync' ? 'active' : ''}" data-mode="sync" title="sync">sync</button>
          <button type="button" class="mode-btn ${state.mode === 'pulse' ? 'active' : ''}" data-mode="pulse" title="pulse">pulse</button>
          <button type="button" class="mode-btn" data-refresh title="fetch">fetch</button>
        </div>
        <div class="session-strip">
          <button type="button" class="session-btn" data-toggle-panel title="focus rail">
            ${state.rightCollapsed ? 'focus' : 'fold'}
          </button>
        </div>
      </header>

      <section class="workspace">
        <section class="shell-panel main-content">
          <div class="main-head">
            <div class="main-copy">
              <span class="main-label">${escapeHtml(page ? page.label : 'Overview')}</span>
              <strong class="main-value">${escapeHtml(state.snapshot.summary)}</strong>
            </div>
            <div class="main-signal">
              ${renderMiniChip('link', state.connection, 'active')}
              ${renderMiniChip('mode', state.mode, 'glue')}
              ${renderMiniChip('note', state.notice, 'tiny')}
            </div>
          </div>
          <div class="content-grid">
            <div class="card-grid">
              ${items.length ? items.map((item, index) => renderCard(item, index, focus)).join('') : renderEmptyState()}
            </div>
            <div class="signal-rail">
              ${items.length ? items.map((item, index) => renderListRow(item, index, focus)).join('') : ''}
            </div>
          </div>
        </section>

        <aside class="shell-panel focus-panel">
          <div class="focus-head">
            <div class="focus-copy">
              <span class="main-label">focus</span>
              <strong class="focus-value">${escapeHtml(focus ? focus.label : 'idle')}</strong>
            </div>
            <button type="button" class="focus-toggle" data-toggle-panel title="collapse focus">
              ${state.rightCollapsed ? '>' : '<'}
            </button>
          </div>
          <div class="focus-body">
            ${renderFocusBody(focus)}
          </div>
          <div class="collapsed-stem">${renderBadge(focus ? focus.label : 'f', 'recommendation', 0)}</div>
        </aside>
      </section>

      <footer class="shell-panel bottom-strip">
        ${statusChips.map((chip, index) => renderStatusChip(chip, index)).join('')}
      </footer>
    </main>
  `;
}

function renderCard(item, index, focus) {
  const active = focus && focus.id === item.id;
  return `
    <button
      type="button"
      class="data-card tone-${item.tone} ${active ? 'active' : ''}"
      data-focus="${item.id}"
      title="${escapeHtml(item.label)}"
    >
      ${renderBadge(item.label, item.tone, index)}
      <span class="card-copy">
        <span class="card-label">${escapeHtml(item.label)}</span>
        <strong class="card-value">${escapeHtml(item.value)}</strong>
        <span class="card-meta">${escapeHtml(item.meta)}</span>
      </span>
    </button>
  `;
}

function renderListRow(item, index, focus) {
  const active = focus && focus.id === item.id;
  return `
    <button
      type="button"
      class="list-row ${active ? 'active' : ''}"
      data-focus="${item.id}"
      title="${escapeHtml(item.label)}"
    >
      ${renderBadge(item.label, item.tone, index + 1)}
      <span class="list-copy">
        <span class="card-label">${escapeHtml(item.label)}</span>
        <strong class="list-value">${escapeHtml(item.value)}</strong>
      </span>
      <span class="list-meta">${escapeHtml(item.meta || item.tone)}</span>
    </button>
  `;
}

function renderFocusBody(focus) {
  if (!focus) {
    return renderEmptyState();
  }

  const detail = focus.detail.length ? focus.detail : state.snapshot.focus.slice(0, 4).flatMap((item) => item.detail).slice(0, 6);
  const orbit = state.snapshot.focus.slice(0, 4);

  return `
    <section class="focus-card tone-${focus.tone}">
      <span class="card-label">${escapeHtml(focus.meta || 'signal')}</span>
      <strong class="focus-main">${escapeHtml(focus.value)}</strong>
    </section>
    <section class="focus-card">
      <div class="detail-grid">
        ${detail.length ? detail.map((item) => `
          <div class="detail-row">
            <span class="card-label">${escapeHtml(item.label)}</span>
            <strong class="detail-value">${escapeHtml(item.value)}</strong>
          </div>
        `).join('') : `
          <div class="detail-row">
            <span class="card-label">state</span>
            <strong class="detail-value">idle</strong>
          </div>
        `}
      </div>
    </section>
    <section class="focus-stack">
      ${orbit.map((item, index) => `
        <button
          type="button"
          class="orbit-chip tone-${item.tone}"
          data-focus="${item.id}"
          title="${escapeHtml(item.label)}"
        >
          ${renderBadge(item.label, item.tone, index + 2)}
          <span class="orbit-copy">
            <span class="card-label">${escapeHtml(item.label)}</span>
            <strong class="detail-value">${escapeHtml(item.value)}</strong>
          </span>
        </button>
      `).join('')}
    </section>
  `;
}

function renderStatusChip(chip, index) {
  return `
    <div class="status-chip tone-${chip.tone || pickTone(chip.label, index)}">
      <span class="status-label">${escapeHtml(chip.label)}</span>
      <strong class="status-value">${escapeHtml(chip.value)}</strong>
    </div>
  `;
}

function renderMiniChip(label, value, tone) {
  return `
    <div class="mini-chip tone-${tone}">
      <span class="status-label">${escapeHtml(label)}</span>
      <strong class="mini-value">${escapeHtml(value)}</strong>
    </div>
  `;
}

function renderBadge(label, tone, index) {
  const shapes = ['circle', 'diamond', 'square', 'pill'];
  const shape = shapes[index % shapes.length];
  return `
    <span class="badge ${shape} tone-${tone}">
      <span class="badge-text">${escapeHtml(String(label).slice(0, 1).toUpperCase())}</span>
    </span>
  `;
}

function renderEmptyState() {
  return `
    <div class="empty-state">
      <span class="card-label">slice</span>
      <strong class="focus-main">clear</strong>
    </div>
  `;
}

function buildUiStatus(page, items) {
  const base = [
    { label: 'link', value: state.connection, tone: 'active' },
    { label: 'mode', value: state.mode, tone: 'glue' },
    { label: 'page', value: page ? page.label : 'overview', tone: 'tiny' },
    { label: 'set', value: String(items.length), tone: 'recommendation' }
  ];

  return base.concat(state.snapshot.statusLine).slice(0, 8);
}

function isStructured(value) {
  return Array.isArray(value) || (value && typeof value === 'object');
}

function previewValue(value) {
  if (Array.isArray(value)) {
    return `${value.length} set`;
  }
  if (value && typeof value === 'object') {
    return trimText(JSON.stringify(value), 52);
  }
  return stringValue(value);
}

function describeValue(value) {
  if (Array.isArray(value)) {
    return 'array';
  }
  if (value && typeof value === 'object') {
    return 'object';
  }
  return typeof value;
}

function pickTone(seed, index) {
  const tones = ['glue', 'active', 'tiny', 'recommendation'];
  return tones[(slug(seed).length + index) % tones.length];
}

function slug(value) {
  return String(value || 'item')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '') || 'item';
}

function firstDefined(...values) {
  for (const value of values) {
    if (value === undefined || value === null) {
      continue;
    }
    if (typeof value === 'string' && value.trim() === '') {
      continue;
    }
    return value;
  }
  return '';
}

function stringValue(value) {
  if (value === undefined || value === null) {
    return '';
  }
  if (typeof value === 'string') {
    return value.trim();
  }
  if (typeof value === 'number' || typeof value === 'boolean') {
    return String(value);
  }
  if (Array.isArray(value)) {
    return `${value.length} set`;
  }
  if (typeof value === 'object') {
    return trimText(JSON.stringify(value), 56);
  }
  return String(value);
}

function trimText(value, length) {
  const text = String(value || '');
  if (text.length <= length) {
    return text;
  }
  return `${text.slice(0, Math.max(0, length - 1))}...`;
}

function escapeHtml(value) {
  return String(value || '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}
