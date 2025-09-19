# app/serializers/move_in_serializer.rb
class MoveInSerializer
  include JSONAPI::Serializer

  attributes :id, :preferred_date, :preferred_time, :status, :checklist

  attribute :attachment_urls, if: proc { |_rec, params| params && params[:action] != :index } do |obj, params|
    if obj.attachments.attached?
      obj.attachments.map { |att| Rails.application.routes.url_helpers.rails_blob_url(att, host: params[:host]) }
    else
      []
    end
  end
end
