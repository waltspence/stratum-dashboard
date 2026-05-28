# Stratum Dashboard

Real-time AI agent operations dashboard. Rails API + Postgres + Redis + Vue 3 SPA.

## Stack

- **API:** Rails 7 (API mode), ActionCable for WebSocket
- **Database:** Postgres 16
- **Real-time:** Redis pub/sub → ActionCable → Vue
- **Jobs:** Sidekiq for HSR audit triggers, health checks
- **Frontend:** Vue 3 + Vite, Lintel dark theme
- **Deploy:** Bare metal (default) or Docker

## Deploy (Bare Metal)

```bash
# Prerequisites: Ruby 3.3+, Node 22+, Postgres 16, Redis 7
./deploy.sh
```

Starts Puma on port 3002. Caddy reverse proxy at `stratum.enlab.dev`.

## Deploy (Docker — optional)

```bash
cp .env.example .env  # set DATABASE_PASSWORD + SECRET_KEY_BASE
docker compose up -d
```

## Dashboard Panels

| Panel | Data Source |
|-------|------------|
| Fleet | Agent status, model, task from API |
| Routing | Super-router decisions (flash/pro/Gemini) |
| HSR Audit | Findings from audit-state.json |
| Health | Gateway, DNS, cron, Tailscale |
| Costs | Token usage per model, 24h spend |
