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
		
		
		@lujack_user = LujackUser.new
		@lujack_user.twitter_usename = @user.screen_name.to_s() #TODO: migrate usename to username, lol
		@favorite_users = @lujack_user.load_favorite_users(client)	
    @tweet_string = "Temporarily out of service"		

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end
end
