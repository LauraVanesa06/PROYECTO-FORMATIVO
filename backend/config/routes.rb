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
  get 'productos', to: 'home#producto'
  get 'contactos', to: 'home#contacto'
  post 'home/contacto/send_report', to: 'home#send_report', as: 'send_report_home_contacto'

  # Dashboard principal
  get 'dashboard', to: 'dashboard#index'
  get 'dashboard/productos', to: 'products#index', as: :inventario
  get 'dashboard/clientes', to: 'dashboard#clientes', as: :clientes
  get 'dashboard/help', to: 'dashboard#help', as: :help
  match 'dashboard/ventas', to: 'buys#index', via: [:get, :post], as: :ventas
  post 'dashboard/send_report', to: 'dashboard#send_report', as: :send_report_dashboard

  # Dashboard - proveedores
  get 'dashboard/suppliers', to: 'suppliers#index', as: :dashboard_suppliers
  post 'dashboard/suppliers', to: 'suppliers#crear_supplier'
  patch 'dashboard/suppliers/:id', to: 'suppliers#actualizar_supplier', as: :dashboard_supplier

  # Recursos principales (RESTful)
  resources :products
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
    end
  end

  resources :purchasedetails

  resources :suppliers do
    get 'products', on: :member
  end

  # API
  namespace :api do
    namespace :v1 do
      get 'buys/por_tipo', to: 'buys#ventas_por_tipo'
      get 'clientes_por_mes', to: 'dashboard#clientes_por_mes'
      get 'dashboard/porcentaje_stock', to: 'dashboard#porcentaje_stock'
      get 'ventas_por_categoria', to: 'dashboard#ventas_por_categoria'
      get 'ventas_por_canal', to: 'dashboard#ventas_por_canal'
      get 'ventas_por_metodo_pago', to: 'dashboard#ventas_por_metodo_pago'
      get 'ventas_periodo', to: 'dashboard#ventas_periodo'
      get 'finanzas', to: 'dashboard#finanzas'
    end
  end

  # Salud del sistema
  get 'up', to: 'rails/health#show', as: :rails_health_check
end
