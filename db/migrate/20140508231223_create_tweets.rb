class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.integer :tweet_id
      t.string :username
      t.integer :lujack_user_id

      t.timestamps
    end
  end
end
