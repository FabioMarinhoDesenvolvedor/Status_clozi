Rails.application.routes.draw do
  resources :clients, except: [ :show ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Used by Render's health check.
  get "up" => "rails/health#show", as: :rails_health_check

  root "clients#index"
end
