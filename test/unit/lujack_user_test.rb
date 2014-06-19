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
end

