class AddMaxIdToLujackUser < ActiveRecord::Migration
  def change
    add_column :lujack_users, :max_id, :integer
  end
end
