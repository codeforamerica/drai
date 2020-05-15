Rails.application.routes.draw do
  root 'hello_worlds#show'

  devise_for :users,
             skip: [:registrations],
             controllers: {
               confirmations: 'account/confirmations',
             },
             path: 'account'

  resource 'account', module: :account, only: [:show, :edit, :update] do
    resource 'setup', only: [:edit, :update], path_names: { edit: '' }
  end

  resources :assisters
  resources :aid_applications, only: [:index]
  resource :privacy, only: [:show]

  resources :organizations, only: [:index], param: :id do
    resources :assisters
    resources :aid_applications, only: [] do
      scope module: :aid_applications do
        resource :eligibility, only: [:edit, :update], path_names: { edit: '' }
        resource :applicant, only: [:edit, :update], path_names: { edit: '' }
        resource :verification, only: [:edit, :update], path_names: { edit: '' }
        resource :approval, only: [:edit, :update], path_names: { edit: '' }
        resource :disbursement, only: [:edit, :update], path_names: { edit: '' }
        resource :duplicate, only: [:show]
      end
    end

    scope module: :organizations do
      resource :dashboard, only: [:show]
      resources :aid_applications, only: [:create, :destroy]
    end
  end

  # honeycrisp gem
  mount Cfa::Styleguide::Engine => "/cfa"
end
