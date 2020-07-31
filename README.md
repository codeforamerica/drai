# DRAI

This is the production code for a tool designed for Assisters/Supervisors of community based organizations(CBOs), and will not be directly accessed by clients.

## Installation

### Setup

Run [`bin/setup`](bin/setup).

### Common Issues

-  If setting up Postgres.app, you will also need to add the binary to your path. e.g. Add to your `~/.zshrc`: `export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin"`

#### Dependencies

_You may already have these installed. Try running the **Setup** instructions above first._

1. [Homebrew](https://brew.sh/) for MacOS.
2. A ruby version manager like [RVM](https://github.com/codeforamerica/howto/blob/master/Ruby.md) or rbenv.
3. Locally installed Ruby of the version defined in `.ruby-version`. Because we are using an older version of Ruby, you may also need to run `gem update --system` before running `gem install bundler` and `bundle install`.
4. Postgres 9.4+ `brew install postgres` or [Postgres.app](https://github.com/codeforamerica/howto/blob/master/PostgreSQL.md).
5. Install system dependencies defined in [Brewfile](Brewfile) with `brew bundle`
6. Chrome and possibly Firefox browsers

## To start the server

Run `bin/rails s`

## Local update

Run `bin/update`

## Testing

- Test suite: `bin/rspec`. For more detailed logging use `bin/rspec --format documentation`.

## Pushing code

If pairing, use [git-duet](https://github.com/git-duet/git-duet). (This will be installed when running `brew bundle`.)

## Deploy

Deploy runs automatically upon pushing to master.

## Accessing the production console

Run `aptible ssh --environment drai-production --app rails`
Then run `bin/rails c`

Use caution as the database is writable in the console.

## Infrastructure

### Overview

- Hosted on Aptible
- The following services that are necessary to be run in production:
  - `bin/rails server`: the webserver
  - `bin/rails jobs:work`: the jobworker (delayed_job)
  - `bin/scheduler`: the cron replacement
  - Postgres is the only service dependency

## Contact

Anule Ndukwu ( @anule )
Ben Sheldon ( @bensheldon )
Kristi Lanzisera ( @stroopwafel79 )
