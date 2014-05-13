class LujackUser < ActiveRecord::Base
  attr_accessible :twitter_username
  attr_accessor :favorite_users, :max_id
  has_many :twitter_users
  has_many :tweets
  
  #get number_of_tweets favorites
  #save to database
  #return true if there aren't any tweets left  
  def incremental_load_tweets(client, number_of_tweets)
    max_id = 0
    favorites = []
    twitter_error_occurred = false
    favorite_users = Array.new
    loaded_all_tweets = false
 		options = {:count => number_of_tweets}
 		options = {:count => 40} #TODO: delete me later
 		 
 		begin
 			favorites = client.favorites(self.twitter_username, options)
		rescue Twitter::Error::TooManyRequests => error
			#We're done here. Perhaps eventually flip back to the app reserve of request?
			twitter_error_occurred = true
		end
		
		if favorites.nil?
			loaded_all_tweets = true
		else
		
			if not favorites.last.nil?
				if self.max_id == favorites.last.id
					loaded_all_tweets = true
				end
				self.max_id = favorites.last.id
			end
		end
		
		save_tweets(favorites)
		
		return loaded_all_tweets
	end
	
	def save_tweets(tweets)
	
		tweets.each do |tweet|
			tweet_database_object = self.tweets.build
			tweet_database_object.username = tweet.user.screen_name.to_s()
			tweet_database_object.tweet_id = tweet.id.to_s
			tweet_database_object.save
		end
	
	end
		 
  def calculate_favorite_users(client)
  	favorites = []
  	favorites = Tweet.find_all_by_lujack_user_id(self.id)
  
  
  	username_to_twitter_user_hash = Hash.new
  				
  	favorites.each do |favorite|		
  		
  		username = favorite.username
  	
			if username_to_twitter_user_hash.key?(username)
			
				twitter_user = username_to_twitter_user_hash[username]
				#25% of the time, swap out the tweet with this one. Not actually random.
				random_number = Random.new.rand(0..1)
				
				if random_number > (0.25)
						twitter_user.random_tweet_id = favorite.tweet_id.to_s
				end
				
				twitter_user.favorite_count = twitter_user.favorite_count + 1
			else
				twitter_user = self.twitter_users.build
				twitter_user.username = username
				twitter_user.random_tweet_id = favorite.tweet_id.to_s
				twitter_user.favorite_count = 1
				username_to_twitter_user_hash[username] = twitter_user
			end		
		end
		
		favorite_users = sort_favorite_users(username_to_twitter_user_hash)
		self.favorite_users = find_random_tweets(client, favorite_users)
		
		return self.favorite_users
	end
	
	def find_random_tweets(client, favorite_users)
		oembed_options = {:hide_media => true, :hide_thread => true}
		twitter_error_occurred = false
		
		#the top ten users get a sample tweet - we limit to ten to keep our oembed requests down (doing it for all tweets would go over our rate limit more often than not)
		for i in 0..9 do
		
			favorite_user = favorite_users[i]
			username = favorite_user.username
			tweet_id = favorite_user.random_tweet_id
			logger.debug("tweet id = " + tweet_id.to_s + " user = " + username.to_s)
			
			if not twitter_error_occurred == true
				begin
					favorite_user.random_tweet_html = client.oembed(tweet_id, oembed_options).html 
				rescue Twitter::Error::TooManyRequests => error
					twitter_error_occurrred = true
				end
			end
		end
		
		return favorite_users
	end
	
	def sort_favorite_users(username_to_twitter_user)
		
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
  
  def clear_previous_twitter_users
  	twitter_users = TwitterUser.find_all_by_lujack_user_id(self.id)
  	
  	twitter_users.each do |twitter_user|
  		twitter_user.destroy
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
