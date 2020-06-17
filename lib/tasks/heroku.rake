namespace :heroku do
  desc 'Heroku release tasks (runs on every code push, before postdeploy task on review app creation)'
  task release: :environment do
    if ActiveRecord::SchemaMigration.table_exists?
      Rake::Task['db:migrate'].invoke
    else
      Rails.logger.info "Database not initialized, skipping database migration."
    end
  end

  desc 'Heroku postdeploy tasks (runs only on review app creation, after release task)'
  task postdeploy: :environment do
    Rake::Task['db:schema:load'].invoke
    Rake::Task['db:seed'].invoke
  end

  desc "Heroku drop tables and reload schema and seeds (schedule to run every night on demo)"
  task db_reset: :environment do
    raise "Cannot run this task in production" if Rails.env.production?

    puts "== Dropping Database Tables =="
    queries = ActiveRecord::Base.connection.tables
                .reject { |table| table.in? ['schema_migrations', 'ar_internal_metadata'] }
                .map do |table|
      "DROP TABLE IF EXISTS #{table} CASCADE"
    end

    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute queries.join('; ')
    end

    puts "== Loading Schema =="
    Rake::Task['db:schema:load'].invoke

    puts "== Seeding Records =="
    Rake::Task['db:seed'].invoke
  end
end
