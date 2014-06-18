require 'test_helper'

class TweetTest < ActiveSupport::TestCase
	test "should not save tweet without username" do
                tweet = Tweet.new
                tweet.lujack_user_id = "123"
                tweet.tweet_id = "456"
                assert_equal(tweet.save, false)
        end

        test "should not save tweet without lujack user id" do
                tweet = Tweet.new
                tweet.username = "alexpelan"
                tweet.tweet_id = "123"
                assert_equal(tweet.save, false)
        end

        test "should not save tweet without tweet id" do
                tweet = Tweet.new
                tweet.username = "alexpelan"
                tweet.lujack_user_id = "123"
                assert_equal(tweet.save, false)
        end


end
