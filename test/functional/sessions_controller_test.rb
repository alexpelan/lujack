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

	test "show should set session variable with username" do
		@controller = SessionsController.new
		get(:show, {:username => "alexpelan"})
	
		assert_equal "alexpelan", session[:username]	
	end

	test "find or create user should find an existing user" do
		@controller = SessionsController.new
		
		get :find_or_create_user, :username => "alexpelan1", :format => "js"
		lujack_user = LujackUser.find_by_twitter_username("alexpelan1")
		assert_not_nil lujack_user
	end

	test "find or create user should create a user that isnt yet in the database" do
		@controller = SessionsController.new
		session["access_token"] = "abc"
		session["access_token_secret"] = "123"

		before = LujackUser.find_by_twitter_username("alexpelan")
		get :find_or_create_user, :username => "alexpelan", :format => "js"
		after = LujackUser.find_by_twitter_username("alexpelan")

		assert_nil before
		assert_not_nil after
	end

	test "find or create user should show error if user tries to query non existent other user" do
		@controller = SessionsController.new

		get :find_or_create_user, :username => "blargle", :format => "js"
		
		assert_equal "That user hasn't created their profile yet.", flash[:error_human_readable]
	end

	test "incremental load tweets should load requested number of tweets" do
		@controller = SessionsController.new
		session["access_token"] = "abc"
		session["access_token_secret"] = "123"		
		session[:total_tweets] = 1600
	
		get :find_or_create_user, :username => "alexpelan", :format => "js"
		get :incremental_load_tweets, :number_of_tweets => "200", :format => "js"

		tweets = Tweet.find_all_by_lujack_user_id(session[:id])

		#database stuff actually happens
		assert_in_delta(200, tweets.count, 1)

		#session state stored properly
		assert_equal 200, session[:tweets_loaded]
	end

	test "incremental load tweets should know when it is finished loading tweets" do
		@controller = SessionsController.new
		session["access_token"] = "abc"
		session["access_token_secret"] = "123"

		get :find_or_create_user, :username => "alexpelan", :format => "js"
		session[:total_tweets] = 150
		get :incremental_load_tweets, :number_of_tweets => "200", :format => "js"

		assert_equal true, assigns["done"]
	
	end

	test "finalize should show error message if id in session isnt in db" do
		@controller = SessionsController.new
		session[:id] = 85
		
		get :finalize, :placeholder => "placeholder", :format => "js"

		assert_equal "Uh, that's not good. Try to sign in again, and hopefully that will work. If not, angrily tweet @alexpelan", flash[:error_human_readable]
 
	end
	
	test "finalize should render results partial" do
		@controller = SessionsController.new
		session[:id] = 1
                session[:has_more_than_2000_tweets] = false
		#Delete all twitter users from the fixture, since we want to build them up again from the tweets
                twitter_users = TwitterUser.find_all_by_lujack_user_id(1)
                twitter_users.each do |twitter_user|
                        twitter_user.destroy
                end

		get :finalize, :placeholder => "placeholder", :format => "js"

		#twitter users should be created
		twitter_users = TwitterUser.find_all_by_lujack_user_id(1)
		assert_operator twitter_users.count, :>, 0

		#results partial should be rendered. This element (amongst others)should be on the page
		#Rails assert_select doesnt like AJAX get responses, so instead we do a regex check against @response.body
		assert_match /<ul class=\\\"favorite_user_list\\\">/, @response.body
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
