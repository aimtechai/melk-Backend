class Api::V1::SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_authenticity_token

  # DELETE /api/v1/logout
  def destroy
    Rails.logger.info "🔎 Authorization header: #{request.headers['Authorization']}"
    Rails.logger.info "🔎 Current user before sign_out: #{current_user&.id}"

    if current_user
      sign_out(:user)
      Rails.logger.info "✅ Signed out user ID: #{current_user&.id}"
      render json: { status: 200, message: "logged out successfully" }, status: :ok
    else
      Rails.logger.warn "⚠ No active session or invalid token."
      render json: { status: 401, message: "Couldn't find an active session." }, status: :unauthorized
    end
  end
  private

  def respond_with(resource, _opts = {})
    render json: {
      status: { code: 200, message: "Logged in sucessfully." },
      data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
    }, status: :ok
  end

  def respond_to_on_destroy
    # if current_user
    #   render json: {
    #     status: 200,
    #     message: "logged out successfully"
    #   }, status: :ok
    # else
    #   render json: {
    #     status: 401,
    #     message: "Couldn't find an active session."
    #   }, status: :unauthorized
    # end
  end
end
