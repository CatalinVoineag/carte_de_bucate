Rails.application.routes.draw do
  root "receipes#index"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :receipes
  resources :saved_receipes
  resources :save_receipes, only: [ :create, :destroy ]
end
