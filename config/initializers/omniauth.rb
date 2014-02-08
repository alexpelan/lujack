Rails.application.config.middleware.use OmniAuth::Builder do

	#this makes /auth/twitter redirect to the twitter sign in, with the consumer key and secret, in that order
	provider :twitter, "your_key_here","your_secret_here"

end