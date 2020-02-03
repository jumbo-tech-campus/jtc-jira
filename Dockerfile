FROM ruby:2.6.5

ARG RAILS_RELATIVE_URL_ROOT

# Installation of dependencies
RUN apt-get update && apt-get install -y apt-utils curl build-essential
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get update && apt-get install -y nodejs

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn


RUN apt-get clean autoclean \
  && apt-get autoremove -y \
  && rm -rf \
    /var/lib/apt \
    /var/lib/dpkg \
    /var/lib/cache \
    /var/lib/log

WORKDIR /app

ADD Gemfile* ./
RUN bundle install

ADD . .
RUN yarn install

RUN bundle exec rails assets:clobber
RUN RAILS_ENV=production RAILS_RELATIVE_URL_ROOT=$RAILS_RELATIVE_URL_ROOT bundle exec rails assets:precompile

CMD bash -c "rm -f /app/tmp/pids/server.pid; bundle exec rails s -p 3001 -b '0.0.0.0'"
