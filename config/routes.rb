Lujack::Application.routes.draw do
	get '/welcome/index', to: 'welcome#index', as: 'index'
	get '/auth/twitter/callback', to: 'sessions#create', as: 'callback'
	get '/profile(/:username)', to: 'sessions#show', as: 'show'
	get '/tweet', to: 'sessions#tweet', as: 'tweet'
	get '/find_or_create_user(/:username)', to: 'sessions#find_or_create_user', as: 'find_or_create_user'
	get '/incremental_load_tweets/:number_of_tweets', to: 'sessions#incremental_load_tweets', as: 'incremental_load_tweets'
	get '/finalize/:placeholder', to: 'sessions#finalize', as: 'finalize'
	get '/about', to: 'pages#about', as: 'about'

  root :to => 'welcome#index'

end
