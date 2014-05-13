class ChangeTweetIdsToBigInts < ActiveRecord::Migration
  def up
 		#remove columns
 		remove_column :lujack_users, :max_id
 		remove_column :tweets, :tweet_id
 		remove_column :twitter_users, :random_tweet_id
 		#add new columns of bigint type
  	add_column :lujack_users, :max_id, :integer, :limit => 8
  	add_column :tweets, :tweet_id, :integer, :limit => 8
  	add_column :twitter_users, :random_tweet_id, :integer, :limit => 8
  end

  def down
  	#remove columns
 		remove_column :lujack_users, :max_id
 		remove_column :tweets, :tweet_id
 		remove_column :twitter_users, :random_tweet_id
 		#add new columns of string type
  	add_column :lujack_users, :max_id, :string
  	add_column :tweets, :tweet_id, :string
  	add_column :twitter_users, :random_tweet_id, :string
  end
end
