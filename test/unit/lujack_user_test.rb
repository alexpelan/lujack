require 'test_helper'

class LujackUserTest < ActiveSupport::TestCase
	test "should not save lujack user without username" do
		lujack_user = LujackUser.new
		assert_equal(lujack_user.save, false)
	end

	test "tweet string should contain first 3 twitter users" do
		first_user = TwitterUser.create(username: "blargle")
		second_user = TwitterUser.create(username: "alex")
		third_user = TwitterUser.create(username: "cnn")
		lujack_user = LujackUser.new
		favorite_users = [first_user, second_user, third_user]
		tweet_string = lujack_user.craft_tweet_string(favorite_users)
		assert_equal(tweet_string, "My favorite tweeters are @blargle, @alex, and @cnn. Check out yours at myfavoritetweeters.herokuapp.com")
	end

	test "is up to date should return different values for new and old lujack users" do
		ActiveRecord::Base.record_timestamps = false #want to override the updated at default functionality so we can set our own
		old_user = LujackUser.new
		old_user.updated_at = 8.days.ago
		old_user_result = old_user.is_up_to_date?
		assert_equal(old_user_result, false)

		new_user = LujackUser.new
		new_user.updated_at = Time.now
		new_user_result = new_user.is_up_to_date?
		assert_equal(new_user_result, true)	
	
		ActiveRecord::Base.record_timestamps = true
	end

	test "destroy tweets and twitter users removes tweets and twitter users from the database" do
		lujack_user = LujackUser.find(1) #alexpelan from our fixture
		lujack_user.destroy_tweets_and_twitter_users
		tweets_linked_to_user = Tweet.find_all_by_lujack_user_id(1)
		twitter_users_linked_to_user = TwitterUser.find_all_by_lujack_user_id(1)
		assert_equal(tweets_linked_to_user.count, 0)
		assert_equal(twitter_users_linked_to_user.count, 0)
	end

	test "ensure sort favorite users produces sorted out" do
		lujack_user = LujackUser.find(1)
		favorite_users = TwitterUser.find_all_by_lujack_user_id(1)
		favorite_users = lujack_user.sort_favorite_users(favorite_users)
		
		for i in 0..favorite_users.count-2
			assert_operator favorite_users[i].favorite_count, :>=, favorite_users[i+1].favorite_count
		end
	end

	test "find random tweets populates random tweet html" do
		lujack_user = LujackUser.find(1)
		lujack_user.client = test_client
		favorite_users = TwitterUser.find_all_by_lujack_user_id(1)
		
		favorite_users = lujack_user.find_random_tweets(favorite_users)
		favorite_users.each do |favorite_user|
			assert_not_nil favorite_user.random_tweet_html
		end
	end

	test "calculate favorite users gives correct results" do
		lujack_user = LujackUser.find(1)
		lujack_user.client = test_client

		#Delete all twitter users from the fixture, since we want to build them up again from the tweets
		twitter_users = TwitterUser.find_all_by_lujack_user_id(1)
		twitter_users.each do |twitter_user|
			twitter_user.destroy
		end

		favorite_users = lujack_user.calculate_favorite_users
	
		for i in 0..favorite_users.count-2
			assert_operator favorite_users[i].favorite_count, :>=, favorite_users[i+1].favorite_count
		end
	end
end

