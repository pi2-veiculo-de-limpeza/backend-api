Rails.application.routes.draw do
  
  resources :users
  
  resources :missions, :only=>[:index, :update, :new, :show, :edit]do
  	member do
  		post :andamento
  	end
  end
  
  resources :vehicles, :only=>[:index, :update, :new, :create, :edit] do
  	member do
  		get :all_missions_vehicle
      post :create_mission
      get :faz_map_reduce
  	end
  end

  #missions
  
  resources :sessions, only: [:create, :destroy]


  #monitory

  post "/peso" => "monitoring#create_monitoring_weight", :as => :peso_create
  post "/volume" => "monitoring#create_monitoring_volume_dump", :as => :volume_create

  get "/peso" => "monitoring#get_weight", :as => :peso_get
  get "/volume" => "monitoring#get_volume_dump", :as => :volume_get
  get "/vehicles/started_mission_now" =>"vehicles#started_mission_now", :as => :started_mission_now
  post "/vehicles/speed" => "vehicles#speed", :as => :speed_vehicle

  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
