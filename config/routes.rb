Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  devise_for :user
  root to: "home#welcome"
  get "up" => "rails/health#show", as: :rails_health_check
  get "cars/:id_car" => "cars#cars", as: :cars
  get "cars1" => "cars#cars1", as: :cars1
  get "cars2" => "cars#cars2", as: :cars2
  get "home" => "home#welcome", as: :welcome


  resources :people
  
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
