Rails.application.routes.draw do
  get "up", to: "rails/health#show", as: :rails_health_check

  # Root
  root "public/home#index"

  # Admin
  namespace :admin do
    root to: "dashboard#index"
    resource :session, only: %i[new create destroy], path: "oturum"

    resources :trainers,     except: :show, path: "egitmenler"
    resources :lessons,      except: :show, path: "dersler"
    resources :testimonials, except: :show, path: "yorumlar"
    resources :users,        except: :show, path: "kullanicilar"
    resources :enrollments,  only: %i[index edit update destroy], path: "basvurular"
  end

  # Public
  scope module: :public do
    resource  :club,     only: :show,  path: "kulubumuz"
    resources :trainers, only: :index, path: "egitmenlerimiz"
    resources :lessons,  only: :index, path: "derslerimiz"
    resource  :gallery,  only: :show,  path: "galeri"

    get "/:discipline/basvuru", to: "enrollments#new", as: :new_enrollment
    post "/:discipline/basvuru", to: "enrollments#create", as: :enrollments
    get "/:discipline/basvuru/tesekkurler", to: "enrollments#thanks", as: :enrollment_thanks
  end

  # PWA routes (uncomment when PWA is enabled)
  # get "manifest", to: "pwa#manifest", as: :pwa_manifest
  # get "service-worker", to: "pwa#service_worker", as: :pwa_service_worker
end
