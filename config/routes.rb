Lujack::Application.routes.draw do
	get "welcome/index"
	get '/auth/twitter/callback', to: 'sessions#create', as: 'callback'
	get '/profile(/:username)', to: 'sessions#show', as: 'show'
	get '/tweet', to: 'sessions#tweet', as: 'tweet'
	get '/results(/:username)', to: 'sessions#results', as: 'results'

  resources :users
   
	controller :users do
		get 'users' => :new
		post 'users' => :list
	end

  root :to => 'welcome#index'

end
