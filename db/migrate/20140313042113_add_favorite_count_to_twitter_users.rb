class AddFavoriteCountToTwitterUsers < ActiveRecord::Migration
  def change
    add_column :twitter_users, :favorite_count, :integer
  end
end
