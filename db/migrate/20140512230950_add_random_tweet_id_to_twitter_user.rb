class AddRandomTweetIdToTwitterUser < ActiveRecord::Migration
  def change
  	add_column :twitter_users, :random_tweet_id, :string
  end
end
