class UsersController < ApplicationController

  # GET /users
  # GET /users.json
  def index
    @users = User.all
    @username = params[:username]
    done = false
    max_id = 0
    favorites = []
    @counts = Hash.new

		twitter_client = Twitter::REST::Client.new do |config|
			config.consumer_key    = ENV['CONSUMER_KEY']
	  	config.consumer_secret = ENV['CONSUMER_SECRET']
	  	config.access_token = "14293877-TSXLFabpJrMn3VWA2r2icOAI2XYkrpGp404kB4L89"
	  	config.access_token_secret = "eMlOs4Ja0LAy8cMADq4TwDfRAWUtWGywh4YGRHMtz21bO"
		end
 		
 		options = {:count => 200}
 		
 		while not done
 			
 			begin
	 			temp_favorites = twitter_client.favorites(@username, options)
				favorites = favorites + temp_favorites
			rescue Twitter::Error::TooManyRequests => error
				#look them up if we can't find them
				logger.debug("twitter error")
				@counts = if File.exists?('counts')
						File.open('counts') do|file|
							Marshal.load(file)
						end
					else
						nil
					end
				done = true
			end
			
				if temp_favorites.nil?
					done = true
				else
				
				if max_id == temp_favorites.last.id
					done = true
				end
				
				max_id = temp_favorites.last.id
			end
			
			options = {:count => 200, :max_id => max_id}
	
		end
		
		favorites.each do |favorite|
			if @counts.key?(favorite.user.screen_name.to_s())
				@counts[favorite.user.screen_name.to_s()] = @counts[favorite.user.screen_name.to_s()] + 1
			else
				@counts[favorite.user.screen_name.to_s()] = 1
			end
		end
		
		@counts = @counts.sort_by{|k,v| v}.reverse
		
		if favorites.count > 200 
			#serialize to a file
			logger.debug("trying to marshal dump")
			File.open('counts','wb') do|file|
				Marshal.dump(@counts,file)
			end
		end


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
