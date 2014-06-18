ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  	# Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  	#
  	# Note: You'll currently still have to declare fixtures explicitly in integration tests
  	# -- they do not yet inherit this setting
  	fixtures :all

  	# Add more helper methods to be used by all tests here...
	
	def initialize_omniauth
		OmniAuth.config.test_mode = true
		OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
			:provider => 'twitter',
			:uid => '14293877'
		})
		return OmniAuth.config.mock_auth[:twitter]
	end

	def teardown_omniauth
		OmniAuth.config.test_mode = false
	end

	def client
	 	#use application only authentication
		@client ||= Twitter::REST::Client.new do |config|
                	config.consumer_key = ENV['CONSUMER_KEY']
                	config.consumer_secret = ENV['CONSUMER_SECRET']
        		config.oauth_token = "14293877-Ncu9b3942RAA9qzdsoDTMoxGSQn0e7hqHsiLUw224"
                	config.oauth_token_secret = ENV['ACCESS_TOKEN_SECRET']

		end

	end
end
