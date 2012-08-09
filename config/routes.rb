DayzGps::Application.routes.draw do

  resources :map_markers

  resources :group_maps do
    resources :group_memberships
    resources :map_markers
  end

  resources :group_memberships

  resources :users, :only => [ :show, :edit, :update ]

  match '/auth/:provider/callback' => 'sessions#create'

  match '/signin' => 'sessions#new', :as => :signin

  match '/signout' => 'sessions#destroy', :as => :signout

  match '/auth/failure' => 'sessions#failure'

  match '/test_backboneio' => 'home#test_backboneio'

  root :to => "home#index"
end
