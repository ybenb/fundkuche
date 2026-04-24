# frozen_string_literal: true

user = User.find_or_initialize_by(email: 'ybenb@zhaw.ch')
user.password = 'zhaw'
user.password_confirmation = 'zhaw'
user.save!
puts "Demo user ready: #{user.email}"
