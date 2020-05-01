namespace :search do
  desc 'refresh materialized views for search'
  task refresh: :environment do
    AidApplicationSearch.refresh
  end
end
