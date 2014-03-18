class CreateLujackUsers < ActiveRecord::Migration
  def change
    create_table :lujack_users do |t|
      t.string :twitter_usename
      t.time :instant_of_update

      t.timestamps
    end
  end
end
