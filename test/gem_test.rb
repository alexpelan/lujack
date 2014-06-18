require "twitter"

client = Twitter::REST::Client.new do |config|
	config.consumer_key = ENV['CONSUMER_KEY']
        config.consumer_secret = ENV['CONSUMER_SECRET']
        config.oauth_token = "14293877-Ncu9b3942RAA9qzdsoDTMoxGSQn0e7hqHsiLUw224"
        config.oauth_token_secret = ENV['ACCESS_TOKEN_SECRET']
end


results = client.favorites("alexpelan", {:count => 200})
p results.count
