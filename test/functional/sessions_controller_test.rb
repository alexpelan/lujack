require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
	#####
	# Routing
	#####
	test "profile should route to show" do
		assert_routing "/profile/alexpelan", {controller: "sessions", action: "show", username: "alexpelan"}
	end

	#####
	# Functional
	#####
	test "incremental load tweets should load correct number of tweets" do
		setup_omniauth
                lujack_user = create_alexpelan_lujack_user
		lujack_user.incremental_load_tweets(200)
                tweets = Tweet.find_all_by_lujack_user_id(lujack_user.id)
                assert_in_delta(200, tweets.count, 1) #Sometimes favorites returns 199 instead of 200 - see https://groups.google.com/forum/#!topic/twitter-ruby-gem/6lWFtF42GQw
                assert_not_nil(lujack_user.max_id)
                teardown_omniauth
        end
	
	test "unauthenticated users cant tweet" do
		@controller = SessionsController.new
		tweet = "garbage tweet"		
		
		get(:tweet, {:tweet => tweet})		
		assert_equal "You're not authenticated to tweet that. Try signing in with Twitter again.", flash[:error_human_readable]

	end

	test "tweets must be less than 140 characters" do
		@controller = SessionsController.new
		tweet = "This is an extremely long tweet, which shouldn't be tweeted by anyone. Why not? Because it won't be allowed by twitter. Luckily we're nice guys and give a warning to the user rather than something harsher, like throwing an error page or exception. Nope, instead we swallow the exception. This has been a stream of consciousness tweet by Alex Pelan."
		session["access_token"] = "abc"
		session["access_token_secret"] = "123"

		get(:tweet, {:tweet => tweet})
		assert_equal "That tweet couldn't be sent on account of its over 140-character-ness.", flash[:error_human_readable]
	end
	
	#test "rate limit error is properly raised and recovered form" do
	#	assert_raise Twitter::Error::TooManyRequests do
	#		force_rate_limit_error
	#	end
	#end
	
	def force_rate_limit_error	
		setup_omniauth
		lujack_user = create_alexpelan_lujack_user	
		
		#force a rate limit error by an infinite loop
		while true do
			lujack_user.client.favorites("alexpelan", {:count => 200})
		end
	end
	
	#####
	# Helpers
	#####

	def create_alexpelan_lujack_user
		lujack_user = LujackUser.new
                lujack_user.twitter_username = "alexpelan"
                lujack_user.save
                lujack_user.client = test_client
		return lujack_user
	end

	def setup_omniauth
		omniauth_auth = initialize_omniauth
                @request.env["omniauth.auth"] = omniauth_auth
		@client = test_client
	end


end
