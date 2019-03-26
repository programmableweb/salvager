FROM ruby:2.4.0

MAINTAINER Shelby Switzer <shelby@civicunrest.com>

# Run updates
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

RUN mkdir /salvager
WORKDIR /salvager

ADD /Gemfile /salvager/Gemfile
ADD /Gemfile.lock /salvager/Gemfile.lock
RUN bundle install

ADD . /salvager

CMD ["bundle exec", "rake", "salvage_transform"]