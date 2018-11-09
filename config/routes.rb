Rails.application.routes.draw do
  
  resources :users
  resources :missions
  resources :vehicles, :only=>[:index, :update, :new, :create, :edit] do
  	member do
  		get :all_missions_vehicle
  	end
  end
  

  resources :sessions, only: [:create, :destroy]

  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
