class UserSerializer
  include JSONAPI::Serializer
  attributes :email

  attribute :roles do |user|
    user.roles.pluck(:name)
  end
end
