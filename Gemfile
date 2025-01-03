# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# use main branch for interactions
gem 'discordrb', github: 'shardlab/discordrb', branch: 'main'

gem 'docopt', '~> 0.6.1'
gem 'httparty', '~> 0.21.0'
gem 'mathematical', '~> 1.6'
gem 'mini_magick', '~> 4.13'

gem 'ffi', '~> 1.16.0'  # lapras is running Ubuntu 20.04, which ships a rubygems version too old for ffi 1.17.0

group :dev do
  gem 'rubocop'
end
