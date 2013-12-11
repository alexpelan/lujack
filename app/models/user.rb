class User < ActiveRecord::Base
  attr_accessible :avatar_url, :bio, :username
end
