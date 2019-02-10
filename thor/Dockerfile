FROM ruby:2.6

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

CMD bash -c "thor cache:all"
