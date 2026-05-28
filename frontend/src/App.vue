<template>
  <div id="app">
    <header class="topbar">
      <span class="topbar-logo">STRATUM</span>
      <span style="color:var(--text-dim);font-size:11px;">MISSION CONTROL</span>
      <span class="topbar-status"><span class="topbar-dot"></span>LIVE</span>
    </header>

    <nav class="sidebar">
      <div class="nav-item" :class="{active:view==='fleet'}" @click="view='fleet'">◈ Fleet</div>
      <div class="nav-item" :class="{active:view==='routing'}" @click="view='routing'">◈ Routing</div>
      <div class="nav-item" :class="{active:view==='audit'}" @click="view='audit'">◈ HSR Audit</div>
      <div class="nav-item" :class="{active:view==='health'}" @click="view='health'">◈ Health</div>
      <div class="nav-item" :class="{active:view==='costs'}" @click="view='costs'">◈ Costs</div>
    </nav>

    <main class="main-panel">
      <!-- Fleet -->
      <template v-if="view==='fleet'">
        <div class="panel" style="grid-column:1/-1">
          <div class="panel-header"><span>Active Agents</span><span>{{ agents.length }}</span></div>
          <div v-for="a in agents" :key="a.id" class="agent-card">
            <div class="agent-name">{{ a.name }}</div>
            <div class="agent-model">{{ a.provider }} / {{ a.model }}</div>
            <div class="agent-status" :class="'status-'+a.status">{{ a.status }} — {{ a.task || 'idle' }}</div>
          </div>
        </div>
      </template>

      <!-- Routing -->
      <template v-if="view==='routing'">
        <div class="panel" style="grid-column:1/-1">
          <div class="panel-header"><span>Model Routing Log</span></div>
          <div v-for="r in routes" :key="r.id" style="padding:6px 0;border-bottom:1px solid var(--border-dim);font-size:11px;">
            <span :style="{color:r.model==='pro'?'var(--cyan)':'var(--green)'}">{{ r.model }}</span>
            <span style="color:var(--text-dim)"> score:{{ r.score }} </span>
            <span style="color:var(--text-secondary)">{{ r.task?.slice(0,60) }}</span>
          </div>
        </div>
      </template>

      <!-- HSR Audit -->
      <template v-if="view==='audit'">
        <div class="panel" style="grid-column:1/-1">
          <div class="panel-header"><span>HSR Findings</span><span>{{ findings.length }}</span></div>
          <div v-for="f in findings" :key="f.id" class="finding-row">
            <span class="finding-severity" :class="'sev-'+f.severity">{{ f.severity }}</span>
            <span style="margin-left:8px;">{{ f.issue?.slice(0,80) }}</span>
            <span style="color:var(--text-dim);margin-left:auto;font-size:10px;">{{ f.location }}</span>
          </div>
        </div>
      </template>

      <!-- Health -->
      <template v-if="view==='health'">
        <div class="panel" style="grid-column:1/-1">
          <div class="panel-header"><span>System Health</span></div>
          <div class="metric-grid">
            <div v-for="h in health" :key="h.service" class="metric">
              <div class="metric-value" :style="{color:h.status==='ok'?'var(--green)':'var(--red)'}">{{ h.status==='ok'?'✓':'✗' }}</div>
              <div class="metric-label">{{ h.service }} <span style="color:var(--text-dim)">{{ h.latency_ms }}ms</span></div>
            </div>
          </div>
        </div>
      </template>

      <!-- Costs -->
      <template v-if="view==='costs'">
        <div class="panel" style="grid-column:1/-1">
          <div class="panel-header"><span>Token Usage (24h)</span></div>
          <div v-for="c in costs" :key="c.model" style="margin-bottom:12px;">
            <div style="display:flex;justify-content:space-between;font-size:11px;">
              <span>{{ c.model }}</span>
              <span style="color:var(--cyan)">${{ c.spend }}</span>
            </div>
            <div class="spend-bar"><div class="spend-fill" :style="{width:c.pct+'%'}"></div></div>
          </div>
        </div>
      </template>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const view = ref('fleet')
const agents = ref([])
const routes = ref([])
const findings = ref([])
const health = ref([])
const costs = ref([])

onMounted(async () => {
  const base = '/api/v1'
  try {
    const [a, f, h] = await Promise.all([
      fetch(base+'/agents').then(r=>r.json()),
      fetch(base+'/audits').then(r=>r.json()),
      fetch(base+'/health').then(r=>r.json()),
    ])
    agents.value = a
    findings.value = f
    health.value = h.services || []
  } catch(e) { console.error(e) }

  // ActionCable for real-time updates
  const protocol = location.protocol === 'https:' ? 'wss:' : 'ws:'
  const ws = new WebSocket(`${protocol}//${location.host}/cable`)
  ws.onmessage = (e) => {
    const msg = JSON.parse(e.data)
    if (msg.type === 'ping') return
    const payload = msg.message
    if (payload?.type === 'agent_update') {
      const idx = agents.value.findIndex(a => a.id === payload.agent.id)
      if (idx >= 0) agents.value[idx] = payload.agent
      else agents.value.push(payload.agent)
    }
    if (payload?.type === 'hsr_finding') findings.value.unshift(payload.finding)
    if (payload?.type === 'health_update') {
      const idx = health.value.findIndex(h => h.service === payload.service.service)
      if (idx >= 0) health.value[idx] = payload.service
    }
    if (payload?.type === 'route_decision') routes.value.unshift(payload.route)
  }
})
</script>
