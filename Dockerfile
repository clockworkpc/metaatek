ARG RUBY_VERSION=3.3.0
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
RUN mkdir -p /rails
WORKDIR /rails

# Install packages needed to build gems and node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl git libvips pkg-config python-is-python3 neovim nano libpq-dev less

# Install JavaScript dependencies
ARG NODE_VERSION=18.3.0
ARG YARN_VERSION=1.22.19
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

# Install application gems
COPY Gemfile* ./
RUN gem install bundler && bundle install --jobs 20 --retry 5
RUN gem install foreman

# Ensure Bootstrap is installed and ready to go
RUN bundle exec rails css:install:bootstrap
RUN bundle exec rails assets:clobber
RUN bundle exec rails assets:precompile

# Copy credentials and keys into the Docker image
# COPY config/credentials.yml.enc config/master.key config/


COPY . /rails

RUN rm -rf tmp/*

ADD . /rails
