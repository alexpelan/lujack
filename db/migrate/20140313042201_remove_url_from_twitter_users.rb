class RemoveUrlFromTwitterUsers < ActiveRecord::Migration
  def up
    remove_column :twitter_users, :url
  end

  def down
    add_column :twitter_users, :url, :string
  end
end
