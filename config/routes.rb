Rails.application.routes.draw do
  post '/sign_up', to: 'users#create'
  post '/sign_in', to: 'sessions#create'
  delete '/sign_out', to: 'sessions#destroy'
  post '/auth/refresh', to: 'sessions#refresh'

  resources :user_buddies
  resources :messages
  resources :users
end
