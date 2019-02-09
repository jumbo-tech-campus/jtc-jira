FROM ruby:2.6

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
# Installation of dependencies
RUN apt-get update -qq \
  && apt-get install -y \
      # Needed for certain gems
    build-essential \
      # Needed for asset compilation
    nodejs \
    # The following are used to trim down the size of the image by removing unneeded data
  && apt-get clean autoclean \
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

CMD bash -c "rm -f /app/tmp/pids/server.pid; bundle exec rails s -p 3001 -b '0.0.0.0'"
