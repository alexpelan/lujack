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

  def show
    if session['access_token'] && session['access_token_secret']
      @user = client.user(include_entities: true)
		end
			
		@lujack_user = LujackUser.find_by_twitter_username("alexpelan")
		
		if not @lujack_user.nil?
			lujack_user_up_to_date = @lujack_user.is_up_to_date?
		end
		
		if lujack_user_up_to_date
			@favorite_users = TwitterUser.find_all_by_lujack_user_id(@lujack_user.id)
		else
			logger.debug("not up to date :_((")
			@lujack_user.save  #this gives it an id
		  @lujack_user.load_lujack_user_from_api(client)	
		  @favorite_users = @lujack_user.favorite_users
			@lujack_user.save_to_database() 		
		end	
		
    @tweet_string = @lujack_user.craft_tweet_string()

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end
end
