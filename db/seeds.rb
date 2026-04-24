# frozen_string_literal: true

User.find_or_create_by(email: 'ybenb@zhaw.ch') do |u|
  u.password = 'zhaw'
  u.password_confirmation = 'zhaw'
end
