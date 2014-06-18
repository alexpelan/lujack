class Tweet < ActiveRecord::Base
  	attr_accessible :lujack_user_id, :tweet_id, :username
  	belongs_to :lujack_user

	validates :lujack_user_id, presence: true
        validates :username, presence: true
        validates :tweet_id, presence: true


end
