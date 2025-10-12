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
    end

  #   resources :ingredients, only: %i[new create], controller: 'previous_teacher_trainings/names', path: 'provider-name'
  #   resources :instructions, only: %i[new create], controller: 'previous_teacher_trainings/dates', path: 'training-dates'
  #   resources :details, only: %i[new create], controller: 'previous_teacher_trainings/details', path: 'training-details'
  end
  # resources :previous_teacher_trainings, only: %i[show update], path: 'previous-teacher-training', controller: 'previous_teacher_trainings/review' do
  #   collection do
  #     get 'start', to: 'previous_teacher_trainings/start#new'
  #     post 'create', to: 'previous_teacher_trainings/start#create', as: :create
  #     get ':previous_teacher_training_id/edit', to: 'previous_teacher_trainings/start#edit', as: :edit
  #     put ':previous_teacher_training_id/update', to: 'previous_teacher_trainings/start#update', as: :update
  #   end
  #
  #   resources :names, only: %i[new create], controller: 'previous_teacher_trainings/names', path: 'provider-name'
  #   resources :dates, only: %i[new create], controller: 'previous_teacher_trainings/dates', path: 'training-dates'
  #   resources :details, only: %i[new create], controller: 'previous_teacher_trainings/details', path: 'training-details'
  # end
end
