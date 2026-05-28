module Api
  module V1
    class HealthController < ApplicationController
      def index
        render json: {
          status: "ok",
          services: [
            { service: "gateway", status: "ok", latency_ms: 23 },
            { service: "dns", status: "ok", latency_ms: 5 },
            { service: "redis", status: "pending", latency_ms: nil },
            { service: "postgres", status: "ok", latency_ms: 2 },
            { service: "steno", status: "pending", latency_ms: nil },
            { service: "super-router", status: "ok", latency_ms: 12 }
          ]
        }
      end
    end
  end
end
