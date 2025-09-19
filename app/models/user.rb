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

  has_one :profile, dependent: :destroy
  has_many :maintenance_requests, dependent: :destroy
  has_many :move_ins, dependent: :destroy

  accepts_nested_attributes_for :profile

  after_create :assign_default_role

  def set_role!(new_role)
    transaction do
      roles.clear
      add_role(new_role)
    end
  end

  def role_name
    roles.first&.name
  end

  private

  def assign_default_role
    set_role!(:tenant) if roles.blank?
  end
end
