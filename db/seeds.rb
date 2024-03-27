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

admin_email = Rails.application.credentials[:admin][:email]
admin_password = Rails.application.credentials[:admin][:password]
test_email = Rails.application.credentials[:test][:email]
test_password = Rails.application.credentials[:test][:password]

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
