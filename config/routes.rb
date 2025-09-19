Rails.application.routes.draw do
  # devise_for :users
  devise_for :users, path: "api/v1", path_names: {
    sign_in: "login",
    sign_out: "logout",
    registration: "signup"
  },
  controllers: {
    sessions: "api/v1/sessions",
    registrations: "api/v1/registrations",
    passwords:  "api/v1/passwords"
  }

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      get "/current_user", to: "current_user#index"
      resources :maintenance_requests do
        member do
          patch :update_status
        end
      end
      resources :move_ins, only: [ :index, :show, :destroy ] do
        collection { put :upsert }      # unified create/update
        member    { patch :update_status }
      end
    end
  end
end
