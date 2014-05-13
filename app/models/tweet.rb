class Tweet < ActiveRecord::Base
  attr_accessible :lujack_user_id, :tweet_id, :username
  belongs_to :lujack_user
end
