class MaintenanceRequest < ApplicationRecord
  belongs_to :user
  belongs_to :assigned_to, class_name: "User", optional: true

  has_many_attached :attachments

  enum :status, { pending: 0, in_progress: 1, completed: 2, canceled: 3 }

  validates :title, presence: true
  # validates :status, inclusion: { in: statuses.keys }
  validate  :attachments_type_and_size

  after_commit :set_request_code, on: :create

  private

  def set_request_code
    update_column(:request_code, "CR-#{format('%04d', id)}")
  end

  def attachments_type_and_size
    # First, ensure any attachments exist
    return unless attachments.attached?

    attachments.each do |att|
      # Check that att.blob is present before accessing it
      next unless att.blob

      unless att.blob.content_type.start_with?("image/") || att.blob.content_type.start_with?("video/")
        errors.add(:attachments, "must be an image or video")
      end

      if att.blob.byte_size > 20.megabytes
        errors.add(:attachments, "each file must be 20MB or smaller")
      end
    end
  end
end
