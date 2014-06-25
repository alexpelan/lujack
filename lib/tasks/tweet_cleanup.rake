namespace :db do
	#tweet records are essentially temporary, so we should clean them up, especially because there are a lot of them.
	task tweet_cleanup: :environment do
		tweets = Tweet.where("updated_at < ?", 1.day.ago)
		tweets.each do |tweet|
			tweet.destroy
		end
	end
end
