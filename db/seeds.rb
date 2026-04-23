# frozen_string_literal: true

User.find_or_create_by(email: 'zhaw@fundkueche.ch') do |u|
  u.password = 'ZHAW'
  u.password_confirmation = 'ZHAW'
end
