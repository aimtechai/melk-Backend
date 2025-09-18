class Api::V1::PasswordsController < Devise::PasswordsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.errors.empty?
      render json: { message: "Password reset instructions sent." }, status: :ok
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
