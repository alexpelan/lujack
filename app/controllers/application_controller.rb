class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def client
   @client ||= Twitter::REST::Client.new do |config|
     config.consumer_key = "your_key_here_or_in_env_variable"
     config.consumer_secret = "your_secret_here_or_in_env_variable"
     config.oauth_token = session['access_token']
     config.oauth_token_secret = session['access_token_secret']
   end
 end
  
end
