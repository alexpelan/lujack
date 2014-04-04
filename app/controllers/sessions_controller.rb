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
	
	def progress
		#if session['access_token'] && session['access_token_secret']
    #  user = client.user(include_entities: true)
    #  username = user.screen_name
    #end
		logger.debug("hello, i am being called")
		#render nothing: true
		respond_to do |format|
			format.js
		end
	end

	def results
		if session['access_token'] && session['access_token_secret']
      user = client.user(include_entities: true)
      @username = user.screen_name
      user_is_authenticated = true
    else
    	@username = params[:username]
    	user_is_authenticated = false
		end
		logger.debug("results was called")
		
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
		  @lujack_user.load_lujack_user_from_api(client)	
		  @favorite_users = @lujack_user.favorite_users
			@lujack_user.save_to_database() 		
		#end	
		
    @tweet_string = @lujack_user.craft_tweet_string(@favorite_users)

    respond_to do |format|
      format.js  
    end
	end

  def show
		@username = params[:username]
  end
end
