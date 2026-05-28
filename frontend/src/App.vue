<template>
  <div id="app">
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
      <div class="panel" style="grid-column:1/-1">
        <div class="panel-header"><span>Active Agents</span><span>{{ agents.length }}</span></div>
        <div v-if="error" style="color:var(--red);font-size:11px;margin-bottom:8px;">{{ error }}</div>
        <div v-for="a in agents" :key="a.id" class="agent-card">
          <div class="agent-name">{{ a.name }}</div>
          <div class="agent-model">{{ a.provider }} / {{ a.model }}</div>
          <div class="agent-status" :class="'status-'+a.status">{{ a.status }} — {{ a.task || 'idle' }}</div>
        </div>
        <div v-if="agents.length===0 && !error" style="color:var(--text-dim);font-size:11px;">Loading...</div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const agents = ref([])
const error = ref(null)

onMounted(async () => {
  try {
    const r = await fetch('/api/v1/agents')
    if (!r.ok) throw new Error(`HTTP ${r.status}`)
    const data = await r.json()
    agents.value = data
  } catch(e) {
    error.value = 'API: ' + e.message
    console.error(e)
  }
})
</script>
