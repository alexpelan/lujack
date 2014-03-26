class RemoveInstantOfUpdateFromLujackUser < ActiveRecord::Migration
  def up
    remove_column :lujack_users, :instant_of_update
  end

  def down
    add_column :lujack_users, :instant_of_update, :time
  end
end
