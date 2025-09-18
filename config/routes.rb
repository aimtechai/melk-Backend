Rails.application.routes.draw do
  devise_for :users
  # devise_for :users, skip: [:sessions, :registrations, :passwords]
  # 👇 Tell Devise to register mapping as :user


  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      devise_for :users,
             #  path: "api/v1",         # URL prefix
             #  scope: :user,           # Mapping name
             skip: [ :all ],
             path_names: {
               sign_in:  "login",
               sign_out: "logout",
               sign_up:  "signup"
             },
             controllers: {
               sessions:      "api/v1/sessions",
               registrations: "api/v1/registrations",
               passwords:     "api/v1/passwords"
             }

      devise_scope :user do
        post "signup", to: "registrations#create"
        post "login",  to: "sessions#create"
        delete "logout", to: "sessions#destroy"
        get  "users/current",        to: "sessions#current_user_info"
        post "passwords/send_otp",   to: "passwords#send_otp"
        post "passwords/verify_otp", to: "passwords#verify_otp"
        put  "passwords/reset",      to: "passwords#reset"
      end
    end
  end
end
