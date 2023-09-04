Rails.application.routes.draw do
  resources :weight_classes
  resources :matches
  resources :fighters
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "fighters#index"
end
