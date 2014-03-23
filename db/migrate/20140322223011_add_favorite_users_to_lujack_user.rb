class AddFavoriteUsersToLujackUser < ActiveRecord::Migration
  def change
    add_column :lujack_users, :favorite_users, :text
  end
end
