Rails.application.routes.draw do
  # All routes in this scope will be prefixed with /locale if an available locale is set. See default_url_options in
  # application_controller.rb and http://guides.rubyonrails.org/i18n.html for more info on this approach.

  namespace :webhooks do
    resource :twilio, controller: :twilio, only: [] do
      post :status
    end
    resource :mailgun, controller: :mailgun, only: [] do
      post :status
      post :inbound
    end
  end

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
    resource :referral_information, only: [:show]

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
            post 'send_password_reset_instructions'
          end
        end
        resource :export, only: [:show, :create]
        resources :aid_applications, only: [:show, :create, :destroy]
      end

      resources :aid_applications, only: [] do
        scope module: :aid_applications do
          resource :eligibility, only: [:edit, :update], path_names: { edit: '' }
          resource :applicant, only: [:edit, :update], path_names: { edit: '' }, defaults: { verify: false } do
            put :unpause
          end
          resource :confirmation, only: [:edit, :update], path_names: { edit: '' } do
            put 'update_contact_information'
          end
          resource :verification, controller: :applicants, only: [:edit, :update], path_names: { edit: '' }, defaults: { verify: true }
          resource :approval, only: [:edit], path_names: { edit: '' } do
            put :approve
            put :reject
            put :unapprove
            put :unreject
          end
          resource :duplicate, only: [:show]
          resource :disbursement, only: [:edit, :update], path_names: { edit: '' }
          resource :finished, only: [:edit, :update], path_names: { edit: '' } do
            post 'reveal_activation_code'
          end
        end
      end
    end
  end

  # honeycrisp gem
  mount Cfa::Styleguide::Engine => "/cfa"
end
