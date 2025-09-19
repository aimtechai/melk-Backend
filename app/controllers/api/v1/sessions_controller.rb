class Api::V1::SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_authenticity_token

  skip_before_action :verify_signed_out_user, only: :destroy

  def destroy
    if user_signed_in?
      sign_out(resource_name)
      render json: { message: "Logged out successfully" }, status: :ok
    else
      render json: { message: "Unauthorized: No valid token" }, status: :unauthorized
    end
  end

  private

  def respond_with(resource, _opts = {})
    render json: {
      message: "Logged in successfully",
      user: UserSerializer.new(resource).serializable_hash[:data][:attributes]
    }, status: :ok
  end
end
