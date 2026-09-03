Rails.application.routes.draw do
  get "up", to: "rails/health#show", as: :rails_health_check

  # Root
  root "public/home#index"

  # Admin
  namespace :admin do
    root to: "dashboard#index"
    resource :session, only: %i[new create destroy]

    resources :trainers,     except: :show, path: "egitmenler"
    resources :lessons,      except: :show, path: "dersler"
    resources :testimonials, except: :show, path: "yorumlar"
    resources :press_items,  except: :show, path: "basinda-biz"
    resources :users,        except: :show, path: "kullanicilar"
    resources :enrollments,  only: %i[index edit update destroy], path: "basvurular"
  end

  # Public
  scope module: :public do
    get "robots.txt", to: "robots#show", as: :robots, defaults: { format: :text }
    get "sitemap.xml", to: "sitemaps#show", as: :sitemap, defaults: { format: :xml }

    resource  :club,     only: :show,  path: "kulubumuz"
    resources :trainers, only: :index, path: "egitmenlerimiz"
    resources :lessons,  only: :index, path: "derslerimiz"
    resource  :gallery,  only: :show,  path: "galeri"
    resources :press_items, only: :index, path: "basinda-biz"

    resource :enrollment, only: %i[new create], path: "basvuru", path_names: { new: "" } do
      get "tesekkurler", action: :thanks, as: :thanks
    end
  end

  if Rails.env.local?
    get "hatalar/:code", to: "errors#show", as: :error_preview, constraints: { code: /[45]\d\d/ }
  end
end
