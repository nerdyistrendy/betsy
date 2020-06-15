require 'simplecov'
SimpleCov.start

ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'
require 'rails/test_help'
require "minitest/rails"
require "minitest/reporters"  
# for Colorized output
#  For colorful output!
Minitest::Reporters.use!(
  Minitest::Reporters::SpecReporter.new,
  ENV,
  Minitest.backtrace_filter
)

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors) # causes out of order output.

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def setup
    OmniAuth.config.test_mode = true
  end

  def mock_auth_hash(merchant)
    return {
      provider: "github",
      info: {
        email: merchant.email,
        nickname: merchant.username,
      },
    }
  end

  def perform_login(merchant = nil)
    merchant ||= Merchant.first
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(merchant))

    # Mock calling the OAuth callback function
    get oauth_callback_path(:github)

    merchant = Merchant.find_by(email: merchant.email)
    # Check that merchant must be saved in db and saved in session after logged in
    expect(merchant).wont_be_nil
    expect(session[:user_id]).must_equal merchant.id
    
    return merchant
  end
end
 