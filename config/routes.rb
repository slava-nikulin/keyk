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
        resource :account, only: %i(create destroy)
        resources :templates
        resources :notes
      end
    end
  end
end
