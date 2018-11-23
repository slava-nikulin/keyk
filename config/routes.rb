Rails.application.routes.draw do
  root 'application#index'

  namespace :api do
    namespace :v1 do
      constraints format: :json do
        resources :sessions, only: :create do
          collection do
            delete :sign_out
          end
        end
        resource :account, only: %i(create destroy) do
          member do
            get :confirm
          end
        end
        resources :templates
        resources :notes
        resources :groups
      end
    end
  end
end
