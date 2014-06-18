require 'test_helper'

class TwitterUserTest < ActiveSupport::TestCase
	
	test "should not save twitter user without username" do
                twitter_user = TwitterUser.new
		twitter_user.lujack_user_id = "123"
		twitter_user.random_tweet_id = "456"
                assert_equal(twitter_user.save, false)
        end
	
	test "should not save twitter user without lujack user id" do
		twitter_user = TwitterUser.new
		twitter_user.username = "alexpelan"
		twitter_user.random_tweet_id = "123"
		assert_equal(twitter_user.save, false)
	end

	test "should not save twitter user without random tweet id" do
		twitter_user = TwitterUser.new
		twitter_user.username = "alexpelan"
		twitter_user.lujack_user_id = "123"
		assert_equal(twitter_user.save, false)
	end

end
