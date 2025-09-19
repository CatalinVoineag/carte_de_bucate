Rails.application.routes.draw do
  root "receipes#index"

  resources :ingredients
  resources :receipes
  get "up" => "rails/health#show", as: :rails_health_check
end
