Rails.application.routes.draw do
  resources :weight_classes
  resources :fighters
  resources :matches do
    member do
      get 'fight'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "fighters#index"
end
