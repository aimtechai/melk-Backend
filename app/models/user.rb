class User < ApplicationRecord
  rolify
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :jwt_authenticatable,
         jwt_revocation_strategy: self

  after_create :assign_default_role

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  private
  def assign_default_role
    self.add_role(:tenant) if self.roles.blank?
  end
end
