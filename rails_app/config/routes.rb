Rails.application.routes.draw do
  
  resources :users
  
  resources :missions, :only=>[:index, :update, :new, :show, :edit]do
  	member do
  		
  	end
  end
  
  resources :vehicles, :only=>[:index, :update, :new, :create, :edit] do
  	member do
  		get :all_missions_vehicle
      post :create_mission
  	end
  end

  #missions
  
  resources :sessions, only: [:create, :destroy]

  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
