class ChangeTweetIdsToStrings < ActiveRecord::Migration
  def up
  	change_column :lujack_users, :max_id, :string
  	change_column :tweets, :tweet_id, :string
  	change_column :twitter_users, :random_tweet_id, :string
  end

  def down
  	change_column :lujack_users, :max_id, :float
  	change_column :tweets, :tweet_id, :float
  	change_column :twitter_users, :random_tweet_id, :float
  end
end
