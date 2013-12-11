class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.text :bio
      t.string :avatar_url

      t.timestamps
    end
  end
end
