class MoveIn < ApplicationRecord
  belongs_to :user

  # Images/videos uploaded in the “Walk-through Upload Images and Videos” box
  has_many_attached :attachments

  # Rails 8 enum syntax with default status
  enum :status, { pending: 0, in_progress: 1, completed: 2, canceled: 3 }

  validates :checklist, presence: true
  validate  :attachments_type_and_size

  before_save :set_checklist_completed_at_if_complete

  # ✅ Helpers
  def checklist_complete?
    checklist.values.all?
  end

  private

  # ✅ Automatically mark checklist completion timestamp
  def set_checklist_completed_at_if_complete
    self.checklist_completed_at = checklist_complete? ? Time.current : nil
  end

  # ✅ Validate attachment type and size
  def attachments_type_and_size
    attachments.each do |att|
      next unless att.blob # safety
      ct = att.blob.content_type.to_s

      unless ct.start_with?("image/") || ct.start_with?("video/")
        errors.add(:attachments, "must be an image or video")
      end

      if att.blob.byte_size.to_i > 500.megabytes
        errors.add(:attachments, "each file must be 500MB or smaller")
      end
    end
  end
end
