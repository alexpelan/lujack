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
			
		@users = Hash.new
    @username = "alexpelan" #params[:username] - hardcoded for now
    done = false
    max_id = 0
    favorites = []
    @counts = Hash.new
    finishearly = true
 		
 		options = {:count => 200}
 		
 		while not done
 			
 			begin
	 			temp_favorites = client.favorites(@username, options)
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
			
			#REMOVE ME after testing
			#if finishearly == true
			#	done = true
			#end
			
			options = {:count => 200, :max_id => max_id}
	
		end
		
		favorites.each do |favorite|
			if @counts.key?(favorite.user.screen_name.to_s())
				@counts[favorite.user.screen_name.to_s()] = @counts[favorite.user.screen_name.to_s()] + 1
			else
				@counts[favorite.user.screen_name.to_s()] = 1
				@users[favorite.user.screen_name.to_s()] = favorite.user
			end
		end
		
		@counts = @counts.sort_by{|k,v| v}.reverse
		
		#this appears to have changed my hash to an array - weird, but I'm rolling with it
		@tweet_string = "My favorite tweeters are @" + @counts[0][0].to_s()  + ", @" + @counts[1][0] + ", and @" + @counts[2][0]  + ". Check out yours at lujack.herokuapp.com"
		
		if favorites.count > 200 
			#serialize to a file
			File.open('counts','wb') do|file|
				Marshal.dump(@counts,file)
			end
		end


    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end
end
