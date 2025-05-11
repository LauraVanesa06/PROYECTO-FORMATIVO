Rails.application.routes.draw do
  
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "dashboard" => "dashboard#index"

  get "inventario" => "dashboard#inventario"
  get 'categorias' => 'dashboard#inventario'

  resources :categories, :suppliers do
    member do
      get :products
    end
  end

  resources :products

  get "ventas" => "dashboard#ventas"
  get "proveedores" => "dashboard#proveedores"
  get "clientes" => "dashboard#clientes"


  root "home#index", as: :authenticated_root
  get 'productos', to: 'productos#productos'
  get 'contactos', to: 'contactos#contacto'

    # Otras rutas que tengas

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
