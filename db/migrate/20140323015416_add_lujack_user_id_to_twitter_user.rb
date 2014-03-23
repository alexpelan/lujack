class AddLujackUserIdToTwitterUser < ActiveRecord::Migration
  def change
    add_column :twitter_users, :lujack_user_id, :integer
  end
end
