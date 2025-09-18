class Api::V1::RegistrationsController < Devise::RegistrationsController
  skip_before_action :verify_authenticity_token
  respond_to :json

  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [
        profile_attributes: [
          :first_name, :last_name, :phone, :address,
          :emergency_contact_name, :emergency_contact_phone,
          { tenant_settings: {} },
          :avatar
        ]
      ]
    )
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        code: 200,
        message: "Signed up successfully.",
        data: {
          user: { email: resource.email, roles: resource.roles.pluck(:name) },
          profile: resource.profile ? ProfileSerializer.new(resource.profile).serializable_hash[:data][:attributes] : nil
        }
      }, status: :ok
    else
      render json: {
        code: 422,
        message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}"
      }, status: :unprocessable_entity
    end
  end
end
