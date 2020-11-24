Rails.application.routes.draw do
  resources :user_buddies
  resources :messages
  resources :users
end
