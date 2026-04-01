# frozen_string_literal: true

OpenAI.configure do |config|
  unless Rails.env.test?
    config.access_token = ENV['OPENAI_API_KEY'] || Rails.application.credentials.openai&.api_key
    config.organization_id = ENV['OPENAI_ORGANIZATION_ID'] || Rails.application.credentials.openai&.organization_id
  end
end
