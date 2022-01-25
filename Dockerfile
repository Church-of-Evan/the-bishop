FROM ruby:3.0

# install gem dependencies
RUN apt-get -y update
RUN apt-get -y install cmake build-essential bison flex libffi-dev libxml2-dev libgdk-pixbuf2.0-dev libcairo2-dev libpango1.0-dev fonts-lyx

# install app
WORKDIR /app

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

# install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# install rest of app
COPY . .

CMD ["bundle", "exec", "main.rb"]
