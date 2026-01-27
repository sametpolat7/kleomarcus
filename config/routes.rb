Rails.application.routes.draw do
  root "public/home#index"

  scope module: :public do
    resources :club, only: [ :index ]
  end
end
