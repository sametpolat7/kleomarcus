Rails.application.routes.draw do
  get "up", to: "rails/health#show", as: :rails_health_check

  # Root
  root "public/home#index"

  # Admin
  namespace :admin do
    root to: "dashboard#index"
    resource :session, only: %i[new create destroy]
  end

  # Public
  scope module: :public do
    resource :club, only: [ :show ] do
      get :trainers
      get :lessons
      get :gallery
    end
  end

  # PWA routes (uncomment when PWA is enabled)
  # get "manifest", to: "pwa#manifest", as: :pwa_manifest
  # get "service-worker", to: "pwa#service_worker", as: :pwa_service_worker
end
