Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :accounts, only: [:create]
      resources :cars, only: [:create] do 
        collection do
          post :payment
        end
      end
      post '/login', to: 'sessions#create'
    end
  end
end
