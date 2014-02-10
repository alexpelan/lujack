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
			
    @username = "alexpelan" #params[:username] - hardcoded for now
    done = false
    max_id = 0
    favorites = []
    @counts = Hash.new
    @tweets = Hash.new
    @tweet_htmls = Hash.new
    @twitter_error_occurred = false
    finishearly = true
    count= 0 
 		
 		options = {:count => 20}
 		oembed_options = {:hide_media => true, :hide_thread => true}
 		
 		while not done
 			
 			begin
	 			temp_favorites = client.favorites(@username, options)
				favorites = favorites + temp_favorites
			rescue Twitter::Error::TooManyRequests => error
				#We're done here. Perhaps eventually flip back to the app reserve of request?
				logger.debug("twitter error above")
				done = true
				@twitter_error_occurred = true
			end
			
				if temp_favorites.nil?
					done = true
				else
				
				if max_id == temp_favorites.last.id
					done = true
				end
				
				max_id = temp_favorites.last.id
			end
			
			#REMOVE ME after testing. 
			if finishearly == true
				done = true
			end
			
			options = {:count => 200, :max_id => max_id}
	
		end
		
		oembedone = false
		
		favorites.each do |favorite|		
			if @counts.key?(favorite.user.screen_name.to_s())
				#25% of the time, swap out the tweet with this one. Not actually random.
				random_number = Random.new.rand(0..1)
				
				if random_number > (0.25)
						@tweets[favorite.user.screen_name.to_s()] = favorite.id
				end
				
				@counts[favorite.user.screen_name.to_s()] = @counts[favorite.user.screen_name.to_s()] + 1
			else
				@counts[favorite.user.screen_name.to_s()] = 1
				@tweets[favorite.user.screen_name.to_s()] = favorite.id
			end
		end
		
		@counts = @counts.sort_by{|k,v| v}.reverse
		
		#the top ten users get a sample tweet - we limit to ten to keep our oembed requests down (doing it for all tweets would go over our rate limit more often than not)
		for i in 0..9 do
			username = @counts[i][0]
			tweet_id = @tweets[username]
			
			if not @twitter_error_occurred == true
				begin
					@tweet_htmls[username] = client.oembed(tweet_id, oembed_options).html 
				rescue Twitter::Error::TooManyRequests => error
					logger.debug("twitter error")
					@twitter_error_occurrred = true
				end
			end
		end
		
		#this appears to have changed my hash to an array - weird, but I'm rolling with it
		@tweet_string = "My favorite tweeters are @" + @counts[0][0].to_s()  + ", @" + @counts[1][0] + ", and @" + @counts[2][0]  + ". Check out yours at lujack.herokuapp.com"
		

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end
end
