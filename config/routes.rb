Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      devise_for :users, controllers: {
        sessions: "api/v1/sessions",
        registrations: "api/v1/registrations",
        passwords: "api/v1/passwords"
      }

      devise_scope :user do
        get "users/current", to: "sessions#current_user_info"
        post "passwords/send_otp", to: "passwords#send_otp"
        post "passwords/verify_otp", to: "passwords#verify_otp"
        put "passwords/reset", to: "passwords#reset"
      end
    end
  end
end
