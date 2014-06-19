require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
	#####
	# Routing
	#####
	test "profile should route to show" do
		assert_routing "/profile/alexpelan", {controller: "sessions", action: "show", username: "alexpelan"}
	end

	#test "callback should route to authenticated users profile" do
	#	setup_omniauth
	#	assert_redirected_to  "/auth/twitter/callback", {controller: "sessions", action: "show", username: "alexpelan"}		
	#end

	#####
	# Functional
	#####
	test "incremental load tweets should load correct number of tweets" do
		setup_omniauth
		lujack_user = LujackUser.new
                lujack_user.twitter_username = "alexpelan"
                lujack_user.save
                lujack_user.client = @client
                lujack_user.incremental_load_tweets(200)
                tweets = Tweet.find_all_by_lujack_user_id(lujack_user.id)
                assert_in_delta(200, tweets.count, 1) #Sometimes favorites returns 199 instead of 200 - see https://groups.google.com/forum/#!topic/twitter-ruby-gem/6lWFtF42GQw
                assert_not_nil(lujack_user.max_id)
                teardown_omniauth
        end

	#####
	# Helpers
	#####

	def setup_omniauth
		omniauth_auth = initialize_omniauth
                @request.env["omniauth.auth"] = omniauth_auth
		@client = client
	end


end
