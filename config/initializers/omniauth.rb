Rails.application.config.middleware.use OmniAuth::Builder do

	#this makes /auth/twitter redirect to the twitter sign in, with the consumer key and secret, in that order
  provider :twitter, ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET']

end