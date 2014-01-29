Rails.application.config.middleware.use OmniAuth::Builder do

	#this makes /auth/twitter redirect to the twitter sign in, with the consumer key and secret, in that order
	provider :twitter, "a1yCzDsBREuEPHN2bRwVyQ", "sL5subSVLU7wtSaEQZSZy6O1lNS8lJeLrI7Nuj0NY"

end