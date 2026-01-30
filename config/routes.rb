Rails.application.routes.draw do
  root "public/home#index"

  scope module: :public do
    resource :club, only: [ :show ] do
      get :trainers, on: :collection
      get :schedules, on: :collection
      get :gallery, on: :collection
    end
  end
end
