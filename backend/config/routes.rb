Rails.application.routes.draw do
  
  devise_for :users, controllers: {
    sessions: 'usuarios/sessions',
    registrations: 'usuarios/registrations',
    passwords: 'usuarios/passwords'
  }




  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "dashboard" => "dashboard#index"

  get 'inventario', to: 'dashboard#inventario', as: 'inventario'
  get "/dashboard/inventario", to: "dashboard#inventario"
  get 'clientes', to: 'dashboard#clientes', as: 'clientes'
  match 'ventas', to: 'dashboard#ventas', via: [:get, :post], as: 'ventas'

  resources :categories do
    member do
      get :products
    end
  end

  resources :customers, :buys do
    member do
      get :purchasedetails
    end
  end

  namespace :api do
    namespace :v1 do
      get 'buys/por_tipo', to: 'buys#por_tipo'
      get 'clientes_por_mes', to: 'dashboard#clientes_por_mes'
      get 'dashboard/porcentaje_stock', to: 'dashboard#porcentaje_stock'
    end
  end

  resources :products
  resources :buys
  resources :purchasedetails

  get "ventas" => "dashboard#ventas"

  # Rutas graficas




  root "home#index", as: :authenticated_root
  get 'productos', to: 'home#producto'
  get 'contactos', to: 'home#contacto'

    # Otras rutas que tengas
    #login

  #rutas proveedores
  get 'dashboard/suppliers', to: 'dashboard#suppliers',  as: 'dashboard_suppliers'
  post 'dashboard/suppliers', to: 'dashboard#crear_supplier'
  get "suppliers" => "dashboard#suppliers"
  patch "dashboard/suppliers/:id", to: "dashboard#actualizar_supplier", as: :dashboard_supplier
resources :suppliers do
  get 'products', to: 'suppliers#products'
end


    devise_scope :user do
      get '/acceso', to: 'usuarios/sessions#new', as: :custom_login
      get '/registro', to: 'usuarios/registrations#new', as: :custom_signup
      get '/olvide-contrasena', to: 'usuarios/passwords#new', as: :custom_new_password
    end
      
  
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
