Rails.application.routes.draw do
  devise_for :users,
             controllers: {
               confirmations: 'account/confirmations',
             },
             path: 'account'

  root 'hello_worlds#show'

  scope module: :account do
    resource 'setup', only: [:edit, :update]
  end

  # honeycrisp gem
  mount Cfa::Styleguide::Engine => "/cfa"
end
