FROM ruby:2.4.0

MAINTAINER Shelby Switzer <shelby@civicunrest.com>

RUN gem install bundler -v '2.0.1'

# Throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY lib/ lib/
COPY script/ script/
COPY .env .env
COPY Rakefile Rakefile

RUN chmod +x ./script/salvage.sh

ENTRYPOINT ["./script/salvage.sh"]

# CMD ["./script/salvage.sh"]