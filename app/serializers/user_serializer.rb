class UserSerializer
  include JSONAPI::Serializer
  attributes :email

  attribute :role do |user|
    user.role_name
  end
end
