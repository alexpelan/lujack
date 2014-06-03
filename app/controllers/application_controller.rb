class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def client
   @client ||= Twitter::REST::Client.new do |config|
     config.consumer_key = ENV['CONSUMER_KEY']
     config.consumer_secret = ENV['CONSUMER_SECRET']
     config.oauth_token = session['access_token']
     config.oauth_token_secret = session['access_token_secret']
   end
  end
  
  def application_reserve_client
  	@application_reserve_client ||= Twitter::REST::Client.new do |config|
  		config.consumer_key = ENV['CONSUMER_KEY']
  		config.consumer_secret = ENV['CONSUMER_SECRET']
  		config.oauth_token = "14293877-Ncu9b3942RAA9qzdsoDTMoxGSQn0e7hqHsiLUw224"
  		config.oauth_token_secret = ENV['ACCESS_TOKEN_SECRET']
  	end 
 	end
  
end
