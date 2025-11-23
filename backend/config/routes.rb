Rails.application.routes.draw do
  # Autenticación (Devise)
  devise_for :users, controllers: {
    sessions: 'usuarios/sessions',
    registrations: 'usuarios/registrations',
    passwords: 'usuarios/passwords'
  }

  devise_scope :user do
    get '/acceso', to: 'usuarios/sessions#new', as: :custom_login
    get '/registro', to: 'usuarios/registrations#new', as: :custom_signup
    get '/olvide-contrasena', to: 'usuarios/passwords#new', as: :custom_new_password
  end

  # Página principal
  root "home#index", as: :authenticated_root
  get 'home/index', to: 'home#index', as: :home_index
  get 'productos', to: 'home#producto', as: :productos
  get 'favoritos', to: 'favorites#index', as: :favoritos
  get 'carrito', to: 'home#carrito', as: :carrito
  get 'notificaciones', to: 'home#notificaciones', as: :notificaciones
  get 'contactos', to: 'home#contacto', as: :contactos
  get '/home/producto_show', to: 'home#producto_show', as: 'producto_show'

  # soporte pagina principal
  post '/contacto/enviar', to: 'home#send_report', as: :send_report

  # Carrito
  resource :cart, only: [:show] do
    post "add_item/:product_id", to: "carts#add_item", as: :add_item
    delete "remove_item/:id", to: "carts#remove_item", as: :remove_item
    patch "update_item/:id", to: "carts#update_item", as: :update_item

    # 🔥 NUEVA RUTA PARA EL CARRITO LATERAL (panel o modal)
    get "side_panel", to: "carts#side_panel", as: :side_panel
  end
  # 👆 esta es la nueva ruta, NO interfiere con nada más


  # Dashboard principal
  get 'dashboard', to: 'dashboard#index'
  get 'dashboard/productos', to: 'products#index', as: :inventario
  get 'dashboard/clientes', to: 'customers#index', as: :clientes
  get 'dashboard/help', to: 'dashboard#help', as: :help
  get 'dashboard/pedidos', to: 'pedidos#index', as: :pedidos
  match 'dashboard/ventas', to: 'buys#index', via: [:get, :post], as: :ventas
  post 'dashboard/send_report', to: 'dashboard#send_report', as: :send_report_dashboard

  # Dashboard - proveedores
  get 'dashboard/suppliers', to: 'suppliers#index', as: :dashboard_suppliers
  post 'dashboard/suppliers', to: 'suppliers#crear_supplier'
  patch 'dashboard/suppliers/:id', to: 'suppliers#actualizar_supplier', as: :dashboard_supplier

  # Traduccion
  scope "(:locale)", locale: /en|es/ do
    root "home#index"
    resources :products do 
      collection do 
        patch :update_disponibilidad
        get :generate_code
      end
    end
  end

  # Recursos principales
  resource :cart, only: [:show]
  resources :favorites, only: [:index, :create, :destroy]
  resources :cart_items, only: [:create, :update, :destroy]
  
  resources :categories do
    member do
      get :products
    end 
  end

  resources :customers do
    member do
      get :purchasedetails
    end
  end

  resources :buys do
    member do
      get :purchasedetails
      get :productos
    end
  end

  resources :pedidos do
    member do
      get :purchasedetails
    end
  end

  resources :purchasedetails

  resources :suppliers do
    get 'products', on: :member
  end

  resources :payments, only: [:new, :create, :show]
  post "/payments/webhook", to: "payments#webhook"
  get  '/payments/widget_token', to: 'payments#widget_token' # opcional: para generar signature desde JS

  # API
  namespace :api do
    namespace :v1 do
      get 'buys/ventas_por_tipo', to: 'buys#ventas_por_tipo'
      get 'clientes_por_mes', to: 'dashboard#clientes_por_mes'
      get 'dashboard/porcentaje_stock', to: 'dashboard#porcentaje_stock'
      get 'ventas_por_categoria', to: 'dashboard#ventas_por_categoria'
      get 'ventas_por_canal', to: 'dashboard#ventas_por_canal'
      get 'ventas_por_metodo_pago', to: 'dashboard#ventas_por_metodo_pago'
      get 'ventas_periodo', to: 'dashboard#ventas_periodo'
      get 'finanzas', to: 'dashboard#finanzas'
      post 'auth/login', to: 'auth#login'
      post 'auth/register', to: 'auth#register'
      get 'auth/me', to: 'auth#me'
      put 'auth/update', to: 'auth#update'
      put 'auth/change-password', to: 'auth#change_password'
      post 'auth/forgot-password', to: 'passwords#forgot_password'
      post 'auth/verify-reset-code', to: 'passwords#verify_reset_code'
      post 'auth/reset-password', to: 'passwords#reset_password'
      resources :cart_items, only: [:index, :update, :destroy, :create]
      resources :favorites, only: [:index, :destroy, :create] do
        member do
          get :check
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :products, only: [:index, :show] do
        collection do
          get :all_products
        end
      end
    end
  end



  # Salud del sistema
  get 'up', to: 'rails/health#show', as: :rails_health_check
end