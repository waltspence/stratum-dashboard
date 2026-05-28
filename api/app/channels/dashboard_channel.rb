class DashboardChannel < ApplicationCable::Channel
  def subscribed
    stream_from "dashboard:events"
  end

  def unsubscribed
    stop_all_streams
  end

  # Broadcast helpers called from Sidekiq jobs or controllers
  def self.agent_update(agent)
    ActionCable.server.broadcast("dashboard:events", {
      type: "agent_update",
      agent: agent.slice(:id, :name, :model, :provider, :status, :task)
    })
  end

  def self.hsr_finding(finding)
    ActionCable.server.broadcast("dashboard:events", {
      type: "hsr_finding",
      finding: finding.slice(:id, :severity, :issue, :location, :target)
    })
  end

  def self.health_update(service)
    ActionCable.server.broadcast("dashboard:events", {
      type: "health_update",
      service: service.slice(:service, :status, :latency_ms)
    })
  end

  def self.route_decision(route)
    ActionCable.server.broadcast("dashboard:events", {
      type: "route_decision",
      route: route.slice(:id, :model, :score, :task, :provider)
    })
  end
end
