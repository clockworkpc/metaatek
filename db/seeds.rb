# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

def create_post(user:, filepath:)
  lines = File.readlines(filepath)
  title = lines.first
  content = lines[1..].join("\n")
  Post.create!(user:, title:, content:)
end

def user_credentials(type:, env:)
  env = env.to_sym
  email = Rails.application.credentials[env][type][:email]
  password = Rails.application.credentials[env][type][:password]
  [email, password]
end

admin_email, admin_password = user_credentials(type: :admin, env: Rails.env)
test_email, test_password = user_credentials(type: :test, env: Rails.env)

begin
  admin_user = User.create!(
    email: admin_email,
    password: admin_password,
    password_confirmation: admin_password
  )

  test_user = User.create!(
    email: test_email,
    password: test_password,
    password_confirmation: test_password
  )
rescue StandardError => e
  Rails.logger.info("User already created: #{e}")
end

if Post.count.zero?
  texts_dir = 'spec/fixtures/hebrew_texts'
  filepaths = Dir.glob("#{texts_dir}/*.txt")

  filepaths.each_with_index do |filepath, i|
    create_post(user: admin_user, filepath:)
    last_text = filepaths.count - 1 == i
    create_post(user: test_user, filepath:) if last_text
  end
end
