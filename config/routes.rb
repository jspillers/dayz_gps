DayzGps::Application.routes.draw do

  resources :group_maps

  resources :users, :only => [ :show, :edit, :update ]

  match '/auth/:provider/callback' => 'sessions#create'

  match '/signin' => 'sessions#new', :as => :signin

  match '/signout' => 'sessions#destroy', :as => :signout

  match '/auth/failure' => 'sessions#failure'

  root :to => "home#index"
end
