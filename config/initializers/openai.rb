# frozen_string_literal: true

OpenAI.configure do |config|
  unless Rails.env.test?
    config.access_token = Rails.application.credentials.openai.api_key!
    config.organization_id = Rails.application.credentials.openai.organization_id!
  end
end
