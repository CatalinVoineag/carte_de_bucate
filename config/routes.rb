Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: "/jobs"
  root "receipes#index"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :receipes, only: %i[index show destroy] do
    collection do
      get "start", to: "receipes/start#new"
      post "create", to: "receipes/start#create", as: :create
    end

    member do
      get "edit", to: "receipes/start#edit"
      put "update", to: "receipes/start#update", as: :update
    end

    resources :ingredients, only: %i[new create], controller: "receipes/ingredients"
    resources :instructions, only: %i[new create], controller: "receipes/instructions"
  end

  resources :save_receipes, only: [ :create, :destroy ]

  resources :saved_receipes, only: %i[index show], controller: "saved_receipes/index" do
    member do
      delete :remove
    end
  end
end
