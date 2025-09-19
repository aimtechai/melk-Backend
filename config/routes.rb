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
      resources :move_ins do
        member do
          patch :update_checklist   # Step 1
          patch :schedule           # Step 2 (requires checklist complete)
          post  :attachments        # Step 3 (add files)
          delete "attachments/:attachment_id", to: "move_ins#destroy_attachment"
          patch :update_status      # (manager action)
        end
      end
    end
  end
end

# Defines the root path route ("/")
# root "posts#index"

# namespace :api, defaults: { format: :json } do
#   namespace :v1 do
#     devise_for :users, controllers: {
#       sessions: "api/v1/sessions",
#       registrations: "api/v1/registrations",
#       passwords: "api/v1/passwords"
#     }

#     devise_scope :user do
#       get "users/current", to: "sessions#current_user_info"
#       post "passwords/send_otp", to: "passwords#send_otp"
#       post "passwords/verify_otp", to: "passwords#verify_otp"
#       put "passwords/reset", to: "passwords#reset"
#     end
#   end
# end
