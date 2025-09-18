class Api::V1::SessionsController < Api::V1::BaseController
  # Allow unauthenticated access to login
  skip_before_action :authenticate_user!, only: [ :create ]

  respond_to :json

  # POST /api/v1/login
  def create
    user = User.find_for_database_authentication(email: params.dig(:user, :email))

    if user&.valid_password?(params.dig(:user, :password))
      user.update!(jti: SecureRandom.uuid) # Rotate JTI on login
      sign_in(user)
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first

      render json: {
        message: "Logged in successfully.",
        user: user,
        token: token
      }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  # GET /api/v1/users/current
  def current_user_info
    Rails.logger.info "Authorization header: #{request.headers['Authorization']}"
    if current_user
      render json: { user: current_user }, status: :ok
    else
      render json: { error: "Invalid or expired token" }, status: :unauthorized
    end
  end

# DELETE /api/v1/logout
def destroy
  Rails.logger.info "Authorization header: #{request.headers['Authorization']}"
  if current_user
    # Capture user before signing out
    user = current_user

    # Tell Devise explicitly which scope to sign out
    sign_out(:user)

    # Rotate JTI to revoke old token
    user.update!(jti: SecureRandom.uuid)

    render json: { message: "Logged out successfully." }, status: :ok
  else
    # Devise couldn’t identify a valid user for this token
    Warden::JWTAuth::RevocationStrategies::JTIMatcher.revoke_jwt(nil, nil) rescue nil
    render json: { error: "Invalid or expired token" }, status: :unauthorized
  end
end
end
