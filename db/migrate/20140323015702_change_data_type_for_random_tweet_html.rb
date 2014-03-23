class ChangeDataTypeForRandomTweetHtml < ActiveRecord::Migration
  def up
  	change_table :twitter_users do |t|
  		t.change :random_tweet_html, :text
  	end
  end

  def down
  	change_table :twitter_users do |t|
  		t.change :random_tweet_html, :string
  	end
  end
end
