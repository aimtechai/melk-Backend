class ProfileSerializer
  include JSONAPI::Serializer
  attributes :first_name, :last_name, :phone, :address,
             :emergency_contact_name, :emergency_contact_phone,
             :tenant_settings

  attribute :avatar_url do |profile|
    Rails.application.routes.url_helpers.url_for(profile.avatar) if profile.avatar.attached?
  end
end
