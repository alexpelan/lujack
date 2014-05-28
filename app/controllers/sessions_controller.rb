class SessionsController < ApplicationController

	def create
    session[:access_token] = request.env['omniauth.auth']['credentials']['token']
    session[:access_token_secret] = request.env['omniauth.auth']['credentials']['secret']
    redirect_to show_path
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
		if session['access_token'] && session['access_token_secret']
      user = client.user(include_entities: true)
      total_tweets = user.favorites_count
      @username = user.screen_name
      user_is_authenticated = true
    else
    	@username = params[:username]
    	user_is_authenticated = false
		end
		
		#@lujack_user = LujackUser.find_by_twitter_username(@username)
		
		#if not @lujack_user.nil?
		#	lujack_user_up_to_date = @lujack_user.is_up_to_date?
		#end
		
		#if (lujack_user_up_to_date or not user_is_authenticated) #if they're not authenticated, they're on someone else's page
			#@favorite_users = TwitterUser.where(lujack_user_id: @lujack_user.id).order("favorite_count DESC").all()
		#elsif user_is_authenticated 
		@lujack_user = LujackUser.new
		@lujack_user.twitter_username = @username
		@lujack_user.save  #this gives it an id
		#end
		
		if total_tweets > 2000 #for rate limiting purposes, we'll only load their last 2000
			total_tweets = 2000
		end
		id = @lujack_user.id
		session[:id] = id
		session[:tweets_loaded] = 0
		session[:total_tweets] = total_tweets
		
		respond_to do |format|
			format.js
		end
	
	end
	
	def incremental_load_tweets
		@done = false
		number_of_tweets = params[:number_of_tweets]
		@total_tweets = session[:total_tweets]
		#load user from database. PANIC if we can't find it
		begin
			@lujack_user = 	LujackUser.find(session[:id])
		rescue ActiveRecord::RecordNotFound
			@error_human_readable = "Uh, that's not good. Try to sign in again, and hopefully that will work. If not, angrily tweet @alexpelan"
			render 'error' and return
		end

		loaded_all_tweets = @lujack_user.incremental_load_tweets(client, number_of_tweets)
		
		if @lujack_user.error_occurred
			@error_human_readable = "Your username has made too many requests to twitter in a short time frame. Try waiting 15 minutes and trying again."
			render 'error' and return
		end
		
		#save state to the session
		session[:tweets_loaded] = session[:tweets_loaded] + number_of_tweets.to_i
		if session[:tweets_loaded] > @total_tweets
			session[:tweets_loaded] = @total_tweets
			@done = true
		end
		
		@tweets_loaded = session[:tweets_loaded]
		@lujack_user.save
		
    respond_to do |format|
      format.js  
    end
	end
	
	def finalize
		#TODO: pull the following shared code out
		begin
			@lujack_user = 	LujackUser.find(session[:id])
		rescue ActiveRecord::RecordNotFound
			@error_human_readable = "Uh, that's not good. Try to sign in again, and hopefully that will work. If not, angrily tweet @alexpelan"
			render 'error' and return
		end
		#END TODO
		
		@favorite_users = @lujack_user.calculate_favorite_users(client)
		
		@tweet_string = @lujack_user.craft_tweet_string(@favorite_users)
		
		reset_session
	end

  def show
  	#TODO: pull the following shared code out
  	if session['access_token'] && session['access_token_secret']
  		begin
	      user = client.user(include_entities: true)
	      @username = user.screen_name
	    rescue Twitter::Error::TooManyRequests => error
	    	@error_human_readable = "Your username has made too many requests to twitter in a short time frame. Try waiting 15 minutes and trying again."
				render 'error' and return
	    end
      user_is_authenticated = true
    else
			@username = params[:username]
		end
		#END TODO
		
		session[:username] = @username
		
  end
end
