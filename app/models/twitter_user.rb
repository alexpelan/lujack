class TwitterUser < ActiveRecord::Base
  attr_accessible :random_tweet_html, :favorite_count, :username
  belongs_to :lujack_user
end
