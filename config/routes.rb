Rails.application.routes.draw do
  root 'hello_worlds#show'

  # honeycrisp gem
  mount Cfa::Styleguide::Engine => "/cfa"
end
