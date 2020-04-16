FROM ruby:2.6.6

# System prerequisites
RUN apt-get update \
 && apt-get -y install build-essential libpq-dev nodejs \
 && rm -rf /var/lib/apt/lists/*

# If you require additional OS dependencies, install them here:
# RUN apt-get update \
#  && apt-get -y install imagemagick nodejs \
#  && rm -rf /var/lib/apt/lists/*

ADD Gemfile /app/
ADD Gemfile.lock /app/
WORKDIR /app
RUN gem install bundler -v $(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -1 | tr -d " ") \
    && bundle config set deployment 'true' \
    && bundle config set with 'production' \
    && bundle install --jobs 4 --retry 3 --frozen

ADD . /app

# Collect assets. This approach is not fully production-ready, but
# will help you experiment with Aptible Deploy before bothering with assets.
# Review https://go.aptible.com/assets for production-ready advice.
RUN set -a \
 && . ./.aptible.env \
 && bin/rails assets:precompile

EXPOSE 3000

CMD ["bin/rails", "s", "-b", "0.0.0.0", "-p", "3000"]