class ProfileSerializer
  include JSONAPI::Serializer
  include Rails.application.routes.url_helpers

  attributes :first_name, :last_name, :phone, :address,
             :emergency_contact_name, :emergency_contact_phone,
             :tenant_settings

  attribute :avatar_url do |profile, params|
    profile.avatar.attached? ? rails_blob_url(profile.avatar, host: params[:host]) : nil
  end
end
