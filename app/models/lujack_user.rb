class LujackUser < ActiveRecord::Base
  attr_accessible :instant_of_update, :twitter_username #TODO: instant_of_update is redundant with built in activerecord functionality
  attr_accessor :favorite_users
  serialize :favorite_users, Array
  has_many :twitter_users
    
  def load_lujack_user_from_api(client)
  	done = false
    max_id = 0
    favorites = []
    twitter_error_occurred = false
    favorite_users = Array.new
    finishearly = true
    oembed_options = {:hide_media => true, :hide_thread => true}
 		options = {:count => 40}
  
  	while not done
  		begin
	 			temp_favorites = client.favorites(self.twitter_username, options)
				favorites = favorites + temp_favorites
			rescue Twitter::Error::TooManyRequests => error
				#We're done here. Perhaps eventually flip back to the app reserve of request?
				done = true
				twitter_error_occurred = true
			end
			
				if temp_favorites.nil?
					done = true
				else
				
					if not temp_favorites.last.nil?
						if max_id == temp_favorites.last.id
							done = true
						end
						max_id = temp_favorites.last.id
					end
				end
			
			#REMOVE ME after testing. 
			if finishearly == true
				done = true
			end
			
			options = {:count => 200, :max_id => max_id}
			
		end
		
		oembedone = false
		
		favorite_users = sort_favorite_users(favorites)
		
		#the top ten users get a sample tweet - we limit to ten to keep our oembed requests down (doing it for all tweets would go over our rate limit more often than not)
		for i in 0..9 do
		
			favorite_user = favorite_users[i]
			username = favorite_user.username
			tweet_id = favorite_user.random_tweet_html
			
			if not twitter_error_occurred == true
				begin
					favorite_user.random_tweet_html = client.oembed(tweet_id, oembed_options).html 
				rescue Twitter::Error::TooManyRequests => error
					twitter_error_occurrred = true
				end
			end
		end
		
  	self.favorite_users = favorite_users
  	
  	if (self.favorite_users.nil?)
  		logger.debug("favorite users is nil while loading from api")
  	end
  	
  end
  
  def sort_favorite_users(favorites)
  	username_to_twitter_user = Hash.new
  				
  	favorites.each do |favorite|		
  		
  		username = favorite.user.screen_name.to_s()
  	
			if username_to_twitter_user.key?(username)
			
				twitter_user = username_to_twitter_user[username]
				#25% of the time, swap out the tweet with this one. Not actually random.
				random_number = Random.new.rand(0..1)
				
				if random_number > (0.25)
						twitter_user.random_tweet_html = favorite.id  #kind of odd, but we set an id here, then swap it out for the HTML later. The only reason we just save the id is to lower the amount of oembed calls to the twitter api
				end
				
				twitter_user.favorite_count = twitter_user.favorite_count + 1
			else
				twitter_user = self.twitter_users.build
				twitter_user.username = username
				twitter_user.random_tweet_html = favorite.id
				twitter_user.favorite_count = 1
				username_to_twitter_user[username] = twitter_user
			end
			
			
		end
		
		#sort the twitter_user objects by favorite_count
		favorite_users = username_to_twitter_user.values
		favorite_users.sort! {|a,b| a.favorite_count <=> b.favorite_count}.reverse!
		
		return favorite_users
  end
 
 	def load_lujack_user_from_database
 		#what happens if they change their username? I guess we'll just create a new entry for now
 		lujack_user = LujackUser.find_by_twitter_username("alexpelan") #self.twitter_username)
 		
 		if lujack_user.nil?
 			return nil
 		else
 			logger.debug("this happened = " + self.inspect)
 			self.favorite_users = TwitterUser.where(lujack_user_id = 1)
 			return lujack_user
 		end

 	end
  
  def save_to_database
 
 		self.favorite_users.each do |twitter_user|
 			twitter_user.save
 		end
  	self.save
 	
  end
  
  def craft_tweet_string
  	#you don't just write a tweet, you CRAFT a tweet
  	return "Temporarily out of service"
  	
  		
		#this appears to have changed my hash to an array - weird, but I'm rolling with it
		#@tweet_string = "My favorite tweeters are @" + @counts[0][0].to_s()  + ", @" + @counts[1][0] + ", and @" + @counts[2][0]  + ". Check out yours at lujack.herokuapp.com"
  	
  end
  
end
