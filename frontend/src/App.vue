<template>
  <header class="topbar">
    <span class="topbar-logo">STRATUM</span>
    <span style="color:var(--text-dim);font-size:11px;">MISSION CONTROL</span>
    <span class="topbar-status"><span class="topbar-dot"></span>LIVE</span>
  </header>

  <nav class="sidebar">
    <div class="nav-item active">◈ Fleet</div>
    <div class="nav-item">◈ Routing</div>
    <div class="nav-item">◈ HSR Audit</div>
    <div class="nav-item">◈ Health</div>
    <div class="nav-item">◈ Costs</div>
  </nav>

  <main class="main-panel">
    <!-- Fleet -->
    <div class="panel panel-full">
      <div class="panel-header"><span>Active Agents</span><span>{{ agents.length }}</span></div>
      <div v-if="error" style="color:var(--red);font-size:11px;">{{ error }}</div>
      <div v-for="a in agents" :key="a.id" class="agent-card">
        <div class="agent-name">{{ a.name }}</div>
        <div class="agent-model">{{ a.provider }} / {{ a.model }}</div>
        <div class="agent-status" :class="'status-'+a.status">{{ a.status }} — {{ a.task || 'idle' }}</div>
      </div>
    </div>

    <!-- Model Routing Distribution -->
    <div class="panel">
      <div class="panel-header"><span>Model Routing (24h)</span></div>
      <div class="chart-wrap"><canvas ref="routeChart"></canvas></div>
    </div>

    <!-- Token Usage -->
    <div class="panel">
      <div class="panel-header"><span>Token Usage (7d)</span></div>
      <div class="chart-wrap"><canvas ref="tokenChart"></canvas></div>
    </div>

    <!-- HSR Audit -->
    <div class="panel">
      <div class="panel-header"><span>HSR Findings</span><span>{{ findings.length }}</span></div>
      <div v-for="f in findings" :key="f.id" class="finding-row">
        <span class="finding-severity" :class="'sev-'+f.severity">{{ f.severity }}</span>
        <span style="margin-left:8px;">{{ f.issue?.slice(0,80) }}</span>
      </div>
      <div v-if="!findings.length" style="color:var(--text-dim);font-size:11px;">No findings</div>
    </div>

    <!-- Health -->
    <div class="panel">
      <div class="panel-header"><span>System Health</span></div>
      <div class="chart-wrap-sm"><canvas ref="healthChart"></canvas></div>
    </div>

    <!-- Cost Summary -->
    <div class="panel">
      <div class="panel-header"><span>Cost Summary (30d)</span></div>
      <div class="chart-wrap"><canvas ref="costChart"></canvas></div>
    </div>

    <!-- Activity Feed -->
    <div class="panel panel-full">
      <div class="panel-header"><span>Recent Activity</span></div>
      <div v-for="e in events" :key="e.id" class="event-row">
        <span class="event-time">{{ e.time }}</span>
        <span :style="{color: e.color}">{{ e.type }}</span>
        <span style="color:var(--text-secondary)">{{ e.detail }}</span>
      </div>
    </div>
  </main>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'

const agents = ref([])
const findings = ref([])
const error = ref(null)
const events = ref([])
const routeChart = ref(null)
const tokenChart = ref(null)
const healthChart = ref(null)
const costChart = ref(null)

const COLORS = { cyan: '#22d3ee', green: '#a3e635', amber: '#f59e0b', red: '#ef4444', purple: '#a855f7', dim: '#334155' }

function makeChart(canvas, type, data, options = {}) {
  return new Chart(canvas, {
    type,
    data,
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { labels: { color: '#94a3b8', font: { size: 9 } } } },
      scales: type === 'bar' || type === 'line' ? {
        x: { ticks: { color: '#64748b', font: { size: 8 } }, grid: { color: '#1e293b' } },
        y: { ticks: { color: '#64748b', font: { size: 8 } }, grid: { color: '#1e293b' }, beginAtZero: true }
      } : {},
      ...options
    }
  })
}

onMounted(async () => {
  try {
    const r = await fetch('/api/v1/agents')
    if (!r.ok) throw new Error(`HTTP ${r.status}`)
    agents.value = await r.json()
  } catch(e) {
    error.value = e.message
  }

  // Seed events
  events.value = [
    { id:1, time:'12:03', type:'AGENT', color:COLORS.cyan, detail:'coordinator started daily briefing' },
    { id:2, time:'12:02', type:'ROUTE', color:COLORS.green, detail:'flash → query scored 1.2 → routed to deepseek-v4-flash' },
    { id:3, time:'11:58', type:'HSR', color:COLORS.amber, detail:'audit complete: 2 medium findings on architecture doc' },
    { id:4, time:'11:45', type:'HEALTH', color:COLORS.green, detail:'gateway health check OK (23ms)' },
    { id:5, time:'11:30', type:'ROUTE', color:COLORS.purple, detail:'pro → complex query scored 6.8 → routed to deepseek-v4-pro' },
  ]

  // Seed findings
  findings.value = [
    { id:1, severity:'medium', issue:'Option A claim assumes perfect reviewer — HSRer is also an LLM', location:'hsr-architecture.md' },
    { id:2, severity:'low', issue:'Stale model name: gemini-2.5 → gemini-3.1', location:'hsr/SKILL.md' },
  ]

  await nextTick()

  // Route distribution — donut
  if (routeChart.value) makeChart(routeChart.value, 'doughnut', {
    labels: ['v4-pro', 'v4-flash', 'gemini-2.5', 'gpt-5.5'],
    datasets: [{
      data: [45, 38, 12, 5],
      backgroundColor: [COLORS.purple, COLORS.green, COLORS.cyan, COLORS.amber],
      borderWidth: 0
    }]
  })

  // Token usage — line
  if (tokenChart.value) makeChart(tokenChart.value, 'line', {
    labels: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],
    datasets: [
      { label: 'Input', data: [120,145,98,210,165,88,132], borderColor: COLORS.cyan, tension: 0.3, pointRadius: 2 },
      { label: 'Output', data: [15,22,10,28,18,8,14], borderColor: COLORS.green, tension: 0.3, pointRadius: 2 }
    ]
  }, { scales: { x:{ ticks:{color:'#64748b',font:{size:8}}, grid:{color:'#1e293b'} }, y:{ ticks:{color:'#64748b',font:{size:8}}, grid:{color:'#1e293b'} } } })

  // Health — horizontal bar
  if (healthChart.value) {
    const h = [
      { service:'gateway', ms:23, color:COLORS.green },
      { service:'dns', ms:5, color:COLORS.green },
      { service:'postgres', ms:2, color:COLORS.green },
      { service:'redis', ms:0, color:COLORS.dim },
      { service:'steno', ms:0, color:COLORS.dim },
      { service:'super-router', ms:12, color:COLORS.green },
    ]
    makeChart(healthChart.value, 'bar', {
      labels: h.map(x=>x.service),
      datasets: [{ data: h.map(x=>x.ms), backgroundColor: h.map(x=>x.color), borderWidth: 0, barThickness: 12 }]
    }, { indexAxis: 'y', scales: { x:{ ticks:{color:'#64748b',font:{size:8}}, grid:{color:'#1e293b'} }, y:{ ticks:{color:'#94a3b8',font:{size:9}}, grid:{display:false} } }, plugins: { legend: { display: false } } })
  }

  // Cost — stacked bar
  if (costChart.value) makeChart(costChart.value, 'bar', {
    labels: ['W1','W2','W3','W4'],
    datasets: [
      { label:'DeepSeek', data:[2.10,1.80,2.40,1.95], backgroundColor:COLORS.purple, borderWidth:0 },
      { label:'Gemini', data:[0.15,0.08,0.22,0.10], backgroundColor:COLORS.cyan, borderWidth:0 },
      { label:'Codex', data:[0.05,0,0,0.12], backgroundColor:COLORS.amber, borderWidth:0 },
    ]
  }, { scales: { x:{ stacked:true, ticks:{color:'#64748b',font:{size:8}}, grid:{color:'#1e293b'} }, y:{ stacked:true, ticks:{color:'#64748b',font:{size:8},callback:v=>'$'+v}, grid:{color:'#1e293b'} } } })
})
</script>
