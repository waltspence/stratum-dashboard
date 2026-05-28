Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :agents, only: [:index, :show]
      resources :audits, only: [:index, :show]
      resources :sessions, only: [:index, :show]
      get "health", to: "health#index"
      get "events/recent", to: "events#recent"
      get "costs/summary", to: "costs#summary"
    end
  end
  mount ActionCable.server => "/cable"
end
