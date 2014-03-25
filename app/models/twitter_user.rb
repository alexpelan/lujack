class TwitterUser < ActiveRecord::Base
  attr_accessible :random_tweet_html, :favorite_count, :username, :lujack_user_id
  belongs_to :lujack_user
end
