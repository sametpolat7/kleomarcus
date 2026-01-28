Rails.application.routes.draw do
  root "public/home#index"

  scope module: :public do
    resource :club, only: [ :show ] do
      get :trainers, on: :collection
    end
  end
end
