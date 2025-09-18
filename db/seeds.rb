# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


# db/seeds.rb
puts "Clearing old data..."
Role.destroy_all
User.destroy_all
Profile.destroy_all

# Helper to create users with profiles and roles
def create_user_with_profile(email:, role:, first_name:, last_name:, phone:, address:, emergency_contact_name:, emergency_contact_phone:, tenant_settings: {})
  user = User.create!(
    email: email,
    password: "password123",
    password_confirmation: "password123"
  )
  user.add_role(role)

  user.create_profile!(
    first_name: first_name,
    last_name: last_name,
    phone: phone,
    address: address,
    emergency_contact_name: emergency_contact_name,
    emergency_contact_phone: emergency_contact_phone,
    tenant_settings: tenant_settings
  )

  user
end

puts "Creating users with profiles and roles..."

manager = create_user_with_profile(
  email: "manager@melk.pm",
  role: :manager,
  first_name: "Maria",
  last_name: "Lopez",
  phone: "555-111-1111",
  address: "100 Manager Ave, Melk City",
  emergency_contact_name: "Carlos Lopez",
  emergency_contact_phone: "555-222-2222"
)

owner = create_user_with_profile(
  email: "owner@melk.pm",
  role: :owner,
  first_name: "Olivia",
  last_name: "Brown",
  phone: "555-333-3333",
  address: "200 Owner Blvd, Melk City",
  emergency_contact_name: "George Brown",
  emergency_contact_phone: "555-444-4444",
)

t1 = create_user_with_profile(
  email: "tenant1@melk.pm",
  role: :tenant,
  first_name: "John",
  last_name: "Doe",
  phone: "555-555-5555",
  address: "Apt 1, 300 Tenant St, Melk City",
  emergency_contact_name: "Jane Doe",
  emergency_contact_phone: "555-666-6666",
  tenant_settings: { notifications: true, preferred_contact_method: "email" }
)

t2 = create_user_with_profile(
  email: "tenant2@melk.pm",
  role: :tenant,
  first_name: "Emily",
  last_name: "Smith",
  phone: "555-777-7777",
  address: "Apt 2, 400 Tenant St, Melk City",
  emergency_contact_name: "Jack Smith",
  emergency_contact_phone: "555-888-8888",
  tenant_settings: { notifications: false, preferred_contact_method: "sms" }
)

puts "\nSeeded Users:"
[ manager, owner, t1, t2 ].each do |u|
  puts "#{u.email} (#{u.roles.pluck(:name).join(', ')}) -> Profile: #{u.profile.first_name} #{u.profile.last_name}"
end
