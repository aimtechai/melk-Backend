class Profile < ApplicationRecord
  belongs_to :user

  has_one_attached :avatar # for Active Storage uploads

  validates :first_name, :last_name, presence: true
end
