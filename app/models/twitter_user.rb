class TwitterUser < ActiveRecord::Base
  	attr_accessible :random_tweet_html, :favorite_count, :username, :lujack_user_id
 	belongs_to :lujack_user

	validates :lujack_user_id, presence: true
	validates :username, presence: true
	validates :random_tweet_id, presence: true

end
