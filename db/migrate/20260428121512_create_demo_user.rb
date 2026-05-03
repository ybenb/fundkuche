# frozen_string_literal: true

class CreateDemoUser < ActiveRecord::Migration[7.0]
  def up
    return if User.exists?(email: 'ybenb@zhaw.ch')

    User.create!(
      email: 'ybenb@zhaw.ch',
      password: 'zhaw',
      password_confirmation: 'zhaw'
    )
  end

  def down; end
end
