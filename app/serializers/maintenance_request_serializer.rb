# class MaintenanceRequestSerializer
#   include JSONAPI::Serializer
#   attributes :id, :title, :description, :location,
#              :status, :allow_entry, :request_code

#   attribute :requested_by do |obj|
#     {
#       id: obj.user.id,
#       email: obj.user.email,
#       name: obj.user.profile&.first_name
#     }
#   end

#   attribute :assigned_to do |obj|
#     obj.assigned_to&.email
#   end

#   attribute :attachments do |object|
#     object.attachments.map { |file| Rails.application.routes.url_helpers.url_for(file) } if object.attachments.attached?
#   end
# end

class MaintenanceRequestSerializer
  include JSONAPI::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :user_id, :title, :description, :location,
             :status, :allow_entry, :assigned_to_user_id,
             :request_code, :created_at, :updated_at

  attribute :attachment_urls do |object|
    if object.attachments.attached?
      object.attachments.map { |att| Rails.application.routes.url_helpers.rails_blob_url(att, only_path: true) }
    else
      []
    end
  end
end
