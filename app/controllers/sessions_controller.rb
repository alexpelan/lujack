class SessionsController < ApplicationController
	#####
	# Controller level exception handling
	#####
	rescue_from 'Twitter::Error::TooManyRequests' do |error|
		@error_human_readable = "Your username has made too many requests to twitter in a short time frame. Try waiting 15 minutes and trying again."
		remove_lujack_user_from_database
		render 'error' and return
	end
	
	def remove_lujack_user_from_database
		if find_lujack_user_from_session
			@lujack_user.destroy_tweets_and_twitter_users
			@lujack_user.destroy
		end
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
	end
		
	def find_or_create_user
		find_user_authentication_information

		@lujack_user = LujackUser.find_by_twitter_username(@username)
	
		if not @lujack_user.nil?
			lujack_user_up_to_date = @lujack_user.is_up_to_date?
			id = @lujack_user.id
			if not lujack_user_up_to_date and @is_user_on_own_page
				@lujack_user.destroy_tweets_and_twitter_users #destroy networked tables since we're going to rebuild them.
			end
		else 
			lujack_user_up_to_date = false
		end
		
		@use_information_from_database = lujack_user_up_to_date or not @is_user_on_own_page	
		update_from_api = @is_user_on_own_page
		if @use_information_from_database
			@favorite_users = TwitterUser.where(lujack_user_id: id).order("favorite_count DESC").all()
			@tweet_string = @lujack_user.craft_tweet_string(@favorite_users)
			logger.debug("interest bool is " + @is_user_on_own_page.to_s)
			render 'finalize' and return
		elsif update_from_api
			@lujack_user = LujackUser.new
			@lujack_user.twitter_username = @username
			@lujack_user.save  #this gives it an id
			id = @lujack_user.id
		end
	
		if @user
                        total_tweets = @user.favorites_count
                end
	
		if total_tweets > 2000 #for rate limiting purposes, we'll only load their last 2000
			total_tweets = 2000
			session[:has_more_than_2000_tweets] = true
		end
		session[:id] = id
		session[:tweets_loaded] = 0
		session[:total_tweets] = total_tweets
	
	end
	
	def incremental_load_tweets
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
			remove_lujack_user_from_database
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
		@has_more_than_2000_tweets = session[:has_more_than_2000_tweets]
		@is_user_on_own_page = true
	
		session[:id] = nil
		session[:tweets_loaded] = nil
		session[:total_tweets] = nil
	end

  	def show
		@username = params[:username]
		session[:username] = @username
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
			if @username == params[:username]
				@is_user_on_own_page = true
			else
				@is_user_on_own_page = false
			end
		else
			@username = params[:username]
			@user_is_authenticated = false
			@is_user_on_own_page = false
		end
  	end
end
