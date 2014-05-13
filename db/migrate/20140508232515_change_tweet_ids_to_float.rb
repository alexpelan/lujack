class ChangeTweetIdsToFloat < ActiveRecord::Migration
  def up
  	change_column :lujack_users, :max_id, :float
  	change_column :tweets, :tweet_id, :float
  end

  def down
  	change_column :lujack_users, :max_id, :integer
  	change_column :tweets, :tweet_id, :float
  end
end
