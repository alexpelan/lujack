class LujackUser < ActiveRecord::Base
  	
	#####
	# Class Members
	#####
	attr_accessible :twitter_username
  	attr_accessor :error_occurred, :client, :application_reserve_client
  	
	#####
	# Associations
	#####
	has_many :twitter_users
  	has_many :tweets
  
	#####
	# Validations 
	#####
	validates :twitter_username, presence: true

	#####
	# Methods
	#####

  	#get number_of_tweets favorites
  	#save to database
  	#return true if there aren't any tweets left  
  	def incremental_load_tweets(number_of_tweets)
  		favorites = []
    		favorite_users = Array.new
   		loaded_all_tweets = false
    		self.error_occurred = false
    		if not self.max_id.nil?
	 		options = {:count => number_of_tweets, :max_id => self.max_id}
	 	else
 		 	options = {:count => number_of_tweets}
 		end
 		
 		 
 		begin
			favorites = self.client.favorites(self.twitter_username, options)
		rescue Twitter::Error::TooManyRequests => error
			begin
				favorites = self.application_reserve_client.favorites(self.twitter_username, options)	
			rescue Twitter::Error::TooManyRequests => error
				self.error_occurred = true
			end
		end
		
		if favorites.count == 0
			loaded_all_tweets = true
		else
		
			if not favorites.last.nil?
				if self.max_id == favorites.last.id
					loaded_all_tweets = true
				end

			end
		end
		
		if not favorites.last.nil?
			self.max_id = favorites.last.id
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

	def save_favorite_users(favorite_users)
		favorite_users.each do |favorite_user|
			favorite_user.save
		end
	end

	def destroy_tweets_and_twitter_users
		tweets = Tweet.find_all_by_lujack_user_id(self.id)
        	tweets.each do |tweet|
        		tweet.destroy
        	end
        
		twitter_users = TwitterUser.find_all_by_lujack_user_id(self.id)
       		twitter_users.each do |twitter_user|
        		twitter_user.destroy
        	end

	end

		 
	def calculate_favorite_users
  		self.error_occurred = false
		favorites = []
  		favorites = Tweet.find_all_by_lujack_user_id(self.id)
 	
		if favorites.count == 0
			self.error_occurred = true
			return nil
		end 
  	
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
		
		favorite_users = sort_favorite_users(username_to_twitter_user_hash.values)
		self.favorite_users = find_random_tweets(favorite_users)
		save_favorite_users(self.favorite_users)	
	
		return self.favorite_users
	end
	
	def find_random_tweets(favorite_users)
		oembed_options = {:hide_media => true, :hide_thread => true}
		
		#the top ten users get a sample tweet - we limit to ten to keep our oembed requests down (doing it for all tweets would go over our rate limit more often than not)
		for i in 0..9 do
		
			if favorite_users[i].nil?
				break
			end		
	
			favorite_user = favorite_users[i]
			username = favorite_user.username
			tweet_id = favorite_user.random_tweet_id
			
			begin
				favorite_user.random_tweet_html = self.client.oembed(tweet_id, oembed_options).html 
			rescue Twitter::Error::TooManyRequests => error
				#try application reserve of requests
				begin
					favorite_user.random_tweet_html = self.application_reserve_client.oembed(tweet_id, oembed_options.html)
				rescue Twitter::Error::TooManyRequests => error
					self.error_occurred = true
				end
			rescue Twitter::Error::Forbidden => error #user has protected their tweets
				favorite_user.random_tweet_html = "This user has protected their tweets."
			end
		end
		
		return favorite_users
	end
	
	def sort_favorite_users(favorite_users)
		
		#sort the twitter_user objects by favorite_count
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
  
  	def craft_tweet_string(favorite_users)
  
  		#you don't just write a tweet, you CRAFT a tweet
		tweet_string = "My favorite tweeters are @" + favorite_users[0].username  + ", @" + favorite_users[1].username + ", and @" + favorite_users[2].username + ". Check out yours at myfavoritetweeters.herokuapp.com"
		return tweet_string
 
  	end
  
end
