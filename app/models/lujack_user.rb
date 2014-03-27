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
 
 	def is_up_to_date?
 
 		if self.updated_at < 7.days.ago
 			return false
 		else
 			return true
 		end
 		
 	end	
  
  def save_to_database
 
 		self.favorite_users.each do |twitter_user|
 			twitter_user.save
 		end
  	self.save
 	
  end
  
  def craft_tweet_string(favorite_users)
  
  	#you don't just write a tweet, you CRAFT a tweet
		tweet_string = "My favorite tweeters are @" + favorite_users[0].username  + ", @" + favorite_users[1].username + ", and @" + favorite_users[2].username + ". Check out yours at lujack.herokuapp.com"
		return tweet_string
 
  end
  
end
