Rails.application.routes.draw do
  # All routes in this scope will be prefixed with /locale if an available locale is set. See default_url_options in
  # application_controller.rb and http://guides.rubyonrails.org/i18n.html for more info on this approach.
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
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

    resource :privacy, only: [:show]

    namespace :admin do
      resources :organizations, only: :index
      resources :users, only: :index
      resources :aid_applications, only: :index
    end


    resources :organizations, only: [] do
      scope module: :organizations do
        resource :dashboard, only: [:show]
        resources :assisters, except: [:destroy] do
          member do
            delete 'deactivate'
            post 'reactivate'
            post 'resend_confirmation_instructions'
          end
        end
        resources :aid_applications, only: [:create, :destroy]
      end

      resources :aid_applications, only: [] do
        scope module: :aid_applications do
          resource :eligibility, only: [:edit, :update], path_names: { edit: '' }
          resource :applicant, only: [:edit, :update], path_names: { edit: '' }
          resource :verification, only: [:edit, :update], path_names: { edit: '' }
          resource :approval, only: [:edit, :update], path_names: { edit: '' }
          resource :duplicate, only: [:show]
          resource :disbursement, only: [:edit, :update], path_names: { edit: '' }
          resource :finished, only: [:edit, :update], path_names: { edit: '' }
        end
      end
    end
  end

  # honeycrisp gem
  mount Cfa::Styleguide::Engine => "/cfa"
end
