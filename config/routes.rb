Rails.application.routes.draw do
  root 'hello_worlds#show'

  devise_for :users,
             skip: [:registrations],
             controllers: {
               confirmations: 'account/confirmations',
             },
             path: 'account'

  as :user do
    get 'account' => 'devise/registrations#edit', as: 'edit_user_registration'
    put 'account' => 'devise/registrations#update', as: 'user_registration'
  end

  namespace :account do
    resource 'setup', only: [:edit, :update], path_names: { edit: '' }
  end

  resources :assisters, only: [:index, :new, :create]

  # honeycrisp gem
  mount Cfa::Styleguide::Engine => "/cfa"
end
