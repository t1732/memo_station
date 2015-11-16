FROM ruby:2.2.3

RUN apt-get update && apt-get install -y nodejs sqlite libsqlite3-dev libxml2 libxslt-dev libxml2-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install -j4 --without development test

COPY . /usr/src/app
COPY ./public /usr/src/app/public

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
