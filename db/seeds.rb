# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Create admin user
admin = User.create!(
  email: 'admin@example.com',
  password: 'password123',
  name: 'Admin User',
  role: 'admin',
  position: 'admin'
)

# Create employee users
employees = [
  { email: 'hr@example.com', name: 'HR Manager', position: 'hr' },
  { email: 'teamlead@example.com', name: 'Team Lead', position: 'team_lead' },
  { email: 'senior@example.com', name: 'Senior Employee', position: 'senior_employee' },
  { email: 'junior@example.com', name: 'Junior Developer', position: 'junior_developer' }
]

employees.each do |employee|
  User.create!(
    email: employee[:email],
    password: 'password123',
    name: employee[:name],
    role: 'employee',
    position: employee[:position]
  )
end

# Create meeting rooms
rooms = [
  { name: 'Conference Room A', capacity: 20, description: 'Large conference room with projector and whiteboard' },
  { name: 'Conference Room B', capacity: 12, description: 'Medium conference room with video conferencing' },
  { name: 'Meeting Room 1', capacity: 6, description: 'Small meeting room for team discussions' },
  { name: 'Meeting Room 2', capacity: 4, description: 'Small meeting room with whiteboard' }
]

rooms.each do |room|
  Room.create!(room)
end

puts "Seed data created successfully!"
