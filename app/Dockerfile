FROM ruby:2.7.2-alpine AS build
WORKDIR /usr/src/app
RUN apk add --update build-base postgresql-dev
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test --jobs 4

FROM ruby:2.7.2-alpine AS runtime
WORKDIR /usr/src/app
RUN apk add --update git libpq tzdata
COPY --from=build /usr/local/bundle /usr/local/bundle
