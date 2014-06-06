class SessionsController < ApplicationController
	#####
	# Controller level exception handling
	#####
	rescue_from 'Twitter::Error::TooManyRequests' do |error|
		@error_human_readable = "Your username has made too many requests to twitter in a short time frame. Try waiting 15 minutes and trying again."
		render 'error' and return
	end
	
	#####
	# Controller Actions
	#####
	def create
		session[:access_token] = request.env['omniauth.auth']['credentials']['token']
		session[:access_token_secret] = request.env['omniauth.auth']['credentials']['secret']
    		find_user_authentication_information
		redirect_to :action => "show", :username => @username
  	end

	def tweet
		if session['access_token'] && session['access_token_secret']
    			@user = client.user(include_entities: true)
		end
		tweet = params[:tweet]
		client.update(tweet)
		redirect_to show_path
	end
		
	def find_or_create_user
		find_user_authentication_information

		@lujack_user = LujackUser.find_by_twitter_username(@username)
		logger.debug("luj = " + @lujack_user.inspect)	
	
		if not @lujack_user.nil?
			lujack_user_up_to_date = @lujack_user.is_up_to_date?
			id = @lujack_user.id
		else 
			lujack_user_up_to_date = false
		end
		
		logger.debug("luj user up to date = " + lujack_user_up_to_date.to_s)
		logger.debug(" on own page = " + @is_user_on_own_page.to_s)	
		use_information_from_database = lujack_user_up_to_date or not @is_user_on_own_page	
		update_from_api = @is_user_on_own_page
		if use_information_from_database
			@favorite_users = TwitterUser.where(lujack_user_id: id).order("favorite_count DESC").all()
			logger.debug("faves = " + @favorite_users.inspect)
			render 'finalize' and return
		elsif update_from_api
			@lujack_user = LujackUser.new
			@lujack_user.twitter_username = @username
			@lujack_user.save  #this gives it an id
			id = @lujack_user.id
			logger.debug("here")
		end
	
		if @user
                        total_tweets = @user.favorites_count
                end
	
		if total_tweets > 2000 #for rate limiting purposes, we'll only load their last 2000
			total_tweets = 2000
		end
		session[:id] = id
		session[:tweets_loaded] = 0
		session[:total_tweets] = total_tweets
		logger.debug(" sess at end of find/create = " + session.inspect)
	
	end
	
	def incremental_load_tweets
		logger.debug("sesh at beginning of incremental = " + session.inspect)
		@done = false
		number_of_tweets = params[:number_of_tweets]
		@total_tweets = session[:total_tweets]
		if not find_lujack_user_from_session
			render 'error' and return
		end

		@lujack_user.client = client
		@lujack_user.application_reserve_client = application_reserve_client
		
		loaded_all_tweets = @lujack_user.incremental_load_tweets(number_of_tweets)

		if @lujack_user.error_occurred
			
			@error_human_readable = "Your username has made too many requests to twitter in a short time frame. Try waiting 15 minutes and trying again."
			render 'error' and return
		end
		
		#save state to the session
		session[:tweets_loaded] = session[:tweets_loaded] + number_of_tweets.to_i
		if session[:tweets_loaded] > @total_tweets or loaded_all_tweets
			session[:tweets_loaded] = @total_tweets
			@done = true
		end
		
		@tweets_loaded = session[:tweets_loaded]
		@lujack_user.save
		
	end
	
	def finalize
		if not find_lujack_user_from_session
			render 'error' and return
		end
		
		@lujack_user.client = client
		@lujack_user.application_reserve_client = application_reserve_client
		@favorite_users = @lujack_user.calculate_favorite_users
		
		#various things can make @favorite_users null, including things I haven't been able to predict.
		if @lujack_user.error_occurred
			@error_human_readable = "Hmm...our brain got a little fried on that one."
			render 'error' and return
		end
		
		@tweet_string = @lujack_user.craft_tweet_string(@favorite_users)
		
		session[:id] = nil
		session[:tweets_loaded] = nil
		session[:total_tweets] = nil
	end

  	def show
		@username = params[:username]
		session[:username] = @username
		logger.debug("@username = " + @username.to_s)
  	end
  
  	#####
  	# Controller helper functions
  	#####
  	def find_lujack_user_from_session
		begin
			@lujack_user = 	LujackUser.find(session[:id])
		rescue ActiveRecord::RecordNotFound
			@error_human_readable = "Uh, that's not good. Try to sign in again, and hopefully that will work. If not, angrily tweet @alexpelan"
			return false
		end
		return true
  	end
  
  	def find_user_authentication_information
  		if session['access_token'] && session['access_token_secret']
	      		@user = client.user(include_entities: true)
			@username = @user.screen_name
      			@user_is_authenticated = true
			logger.debug("params = " + params.inspect)
			logger.debug("usernames = " + @username.to_s)
			if @username == params[:username]
				logger.debug("we equal")
				@is_user_on_own_page = true
			else
				logger.debug("not eq")
				@is_user_on_own_page = false
			end
		else
			@username = params[:username]
			@user_is_authenticated = false
			@is_user_on_own_page = false
		end
		logger.debug("is user on own page " + @is_user_on_own_page.to_s)
  	end
end
