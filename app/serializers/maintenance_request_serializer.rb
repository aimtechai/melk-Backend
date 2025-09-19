class MaintenanceRequestSerializer
  include JSONAPI::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :title, :description, :location,
             :status, :allow_entry, :request_code

  attribute :requested_by do |obj|
    {
      id: obj.user.id,
      email: obj.user.email,
      name: obj.user.profile&.first_name
    }
  end

  attribute :assigned_to do |obj|
    obj.assigned_to&.email
  end

  attribute :attachment_urls, if: proc { |_record, params| params && params[:action] == :create } do |object, params|
    if object.attachments.attached?
      object.attachments.map do |att|
        Rails.application.routes.url_helpers.rails_blob_url(att, host: params[:host])
      end
    else
      []
    end
  end
end
