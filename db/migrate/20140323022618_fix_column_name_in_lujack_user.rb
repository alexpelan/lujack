class FixColumnNameInLujackUser < ActiveRecord::Migration
  def up
  	rename_column :lujack_users, :twitter_usename, :twitter_username
  end

  def down
  	rename_column :lujack_users, :twitter_username, :twitter_usename
  end
end
