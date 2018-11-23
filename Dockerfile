FROM ruby:2.5.1-slim

RUN apt update && apt install build-essential libpq-dev nodejs postgresql postgresql-contrib git tzdata vim -y

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install --binstubs

COPY . .
RUN ["chmod", "+x", "wait-for-postgres.sh"]

CMD puma -C config/puma.rb
