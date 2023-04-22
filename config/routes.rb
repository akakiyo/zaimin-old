Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :transactions, only: [:create] do
    collection do
      get :redirect
      get :callback
      get :test
    end
  end
end
