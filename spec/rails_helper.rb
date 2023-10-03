# frozen_string_literal: true

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'selenium/webdriver'
require 'vcr'
require 'super_diff/rspec-rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

VCR.configure do |config|
  config.ignore_hosts '127.0.0.1', 'localhost', 'chromedriver.storage.googleapis.com'
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!

  # do not record new cassettes if on CI
  config.default_cassette_options = { record: ENV['CI'] ? :none : :new_episodes }

  config.filter_sensitive_data('<GOUPC_API_KEY>') { Rails.application.credentials.goupc[:api_key] }
  config.filter_sensitive_data('<ULTRALYTICS_API_KEY>') { Rails.application.credentials.ultralytics[:api_key] }
  config.filter_sensitive_data('<OPENAI_API_KEY>') { Rails.application.credentials.openai[:api_key] }
end

RSpec.configure do |config|
  config.include ActiveJob::TestHelper
  config.include ActiveSupport::Testing::TimeHelpers
  config.include FactoryBot::Syntax::Methods
  config.include JavaScriptErrorReporter, type: :system, js: true

  config.fixture_path = Rails.root.join('spec/fixtures')
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before do |example|
    ActionMailer::Base.deliveries.clear
    I18n.locale = I18n.default_locale
    Faker::UniqueGenerator.clear
    Rails.logger.debug { "--- #{example.location} ---" }
  end

  config.after do |example|
    Rails.logger.debug { "--- #{example.location} FINISHED ---" }
  end

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, :js, type: :system) do
    driven_by ENV['SELENIUM_DRIVER']&.to_sym || :selenium_chrome_headless
  end

  Shoulda::Matchers.configure do |c|
    c.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
end
