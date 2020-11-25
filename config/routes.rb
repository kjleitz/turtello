Rails.application.routes.draw do
  post '/sign_up', to: 'users#create', as: :sign_up
  post '/sign_in', to: 'sessions#create', as: :sign_in
  delete '/sign_out', to: 'sessions#destroy', as: :sign_out
  post '/auth/refresh', to: 'sessions#refresh', as: :refresh

  resources :user_buddies
  resources :messages
  resources :users
end
