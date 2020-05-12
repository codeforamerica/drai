web: bin/rails server
worker: bin/scheduler & bin/rails jobs:work & wait -n
release: bin/rails heroku:release
scheduler: bin/scheduler
delayed_job: bin/rails jobs:work