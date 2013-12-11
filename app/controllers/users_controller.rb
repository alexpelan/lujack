class UsersController < ApplicationController

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
  	@user = User.new
 		
 		
 		 	
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])
    @username = params[:username]
    done = false
    favorites = []
    counts = Hash.new

		twitter_client = Twitter::REST::Client.new do |config|
			config.consumer_key    = "a1yCzDsBREuEPHN2bRwVyQ"
	  	config.consumer_secret = "sL5subSVLU7wtSaEQZSZy6O1lNS8lJeLrI7Nuj0NY"
	  	config.access_token = "14293877-TSXLFabpJrMn3VWA2r2icOAI2XYkrpGp404kB4L89"
	  	config.access_token_secret = "eMlOs4Ja0LAy8cMADq4TwDfRAWUtWGywh4YGRHMtz21bO"
		end
 		
 		if(!@username.nil?)
 			logger.debug("user = " + @username)
 		end
 		
 		options = {:count => 200}
 		
 		while not done
 			
 			begin
	 			temp_favorites = twitter_client.favorites(@username, options)
				favorites = favorites + temp_favorites
			rescue Twitter::Error::TooManyRequests => error
				logger.debug("twitter error")
				done = true
			end
			
			if temp_favorites.nil?
				done = true
				logger.debug("temp favs is null")
			else
				logger.debug("temp faves is not null")
				max_id = temp_favorites.last.id
				logger.debug("max id = " + max_id.to_s())
			end
			
			options = {:count => 200, :max_id => max_id}
	
		end
		
		favorites.each do |favorite|
			if counts.key?(favorite.user.screen_name.to_s())
				logger.debug("found user already here: " + favorite.user.screen_name.to_s())
				counts[favorite.user.screen_name.to_s()] = counts[favorite.user.screen_name.to_s()] + 1
			else
				counts[favorite.user.screen_name.to_s()] = 1
				logger.debug("found new user " + favorite.user.screen_name.to_s())
			end
		end
		
		counts.each do |username, count|
			logger.debug("@"+ username.to_s() + " " + count.to_s())
		end

    respond_to do |format|
      #if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      #else
      #  format.html { render action: "new" }
      #  format.json { render json: @user.errors, status: :unprocessable_entity }
      #end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
