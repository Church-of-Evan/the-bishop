FROM ruby:3.1

# install gem dependencies
RUN apt-get -qq update -y

RUN apt-get -qq install -y \
    cmake build-essential bison flex libffi-dev libxml2-dev libwebp-dev \
    libzstd-dev libgdk-pixbuf2.0-dev libcairo2-dev libpango1.0-dev fonts-lyx

# install app
WORKDIR /app

# throw errors if Gemfile is out of sync with Gemfile.lock
RUN bundle config --global frozen 1

# install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# install rest of app
COPY . .

CMD ["bundle", "exec", "main.rb"]
