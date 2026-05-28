module Api
  module V1
    class AgentsController < ApplicationController
      def index
        render json: JSON.parse(stratum_bridge("agents"))
      rescue => e
        render json: [{ id: 0, name: "error", model: e.message, provider: "bridge", status: "error", task: nil }]
      end

      private

      def stratum_bridge(cmd)
        `python3 #{ENV['HOME']}/stratum/scripts/bridge.py #{cmd}`
      end
    end
  end
end
