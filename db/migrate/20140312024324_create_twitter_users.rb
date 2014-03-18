class CreateTwitterUsers < ActiveRecord::Migration
  def change
    create_table :twitter_users do |t|
      t.string :username
      t.string :random_tweet_html
      t.string :url

      t.timestamps
    end
  end
end
