#!/usr/bin/env bash
set -euo pipefail

# Stratum Dashboard — bare metal deploy (same pattern as jarvis)
# Requires: Ruby 3.3+, Node 22+, Postgres 16, Redis 7

DASHBOARD_ROOT="$(cd "$(dirname "$0")" && pwd)"

export RAILS_ENV=production
export PATH="$HOME/.rbenv/shims:$HOME/.rbenv/bin:/opt/homebrew/opt/node@22/bin:/usr/bin:/bin"

echo "=== Stratum Dashboard Deploy ==="

echo "--- Building frontend ---"
cd "$DASHBOARD_ROOT/frontend"
npm ci --silent
npm run build

echo "--- Installing gems ---"
cd "$DASHBOARD_ROOT/api"
bundle config set --local deployment true
bundle config set --local without "development test"
bundle install --quiet

echo "--- Running migrations ---"
bundle exec rails db:create 2>/dev/null || true
bundle exec rails db:migrate

echo "--- Restarting server ---"
bundle exec pumactl -P tmp/pids/puma.pid restart 2>/dev/null || \
  bundle exec puma -C config/puma.rb -d

echo "✓ Dashboard deployed at http://localhost:3002"
