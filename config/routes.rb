Rails.application.routes.draw do
  namespace :saved_receipes do
    get "start/new"
    get "start/create"
  end
  root "receipes#index"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :receipes
  resources :save_receipes, only: [ :create, :destroy ]

  resources :saved_receipes, only: %i[index show], controller: "saved_receipes/index" do
    collection do
      get "start", to: "saved_receipes/start#new"
      post "create", to: "saved_receipes/start#create", as: :create
      get ":saved_receipe_id/edit", to: "saved_receipes/start#edit", as: :edit
      put ":saved_receipe_id/update", to: "saved_receipes/start#update", as: :update
    end

    resources :ingredients, only: %i[new create], controller: "saved_receipes/ingredients"
    resources :instructions, only: %i[new create], controller: "saved_receipes/instructions"
  end
end
