module Api
  module V1
    class AgentsController < ApplicationController
      def index
        render json: [
          { id: 1, name: "coordinator", model: "deepseek-v4-pro", provider: "deepseek", status: "active", task: "daily briefing" },
          { id: 2, name: "scout", model: "deepseek-v4-flash", provider: "deepseek", status: "idle", task: nil },
          { id: 3, name: "hsr-reviewer", model: "gemini-2.5-flash-lite", provider: "gemini", status: "active", task: "audit running" }
        ]
      end
    end
  end
end
