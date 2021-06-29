# frozen_string_literal: true

source 'https://rubygems.org'
# source 'http://mirror.ops.rhcloud.com/mirror/ruby/'
ruby '2.7.3'

# PRESENTATION LAYER
gem 'multi_json'
gem 'roar'

# APPLICATION LAYER
# Web application related
gem 'econfig'
gem 'puma'
gem 'rack-cache'
gem 'redis'
gem 'redis-rack-cache'
gem 'roda'

# Controllers and services
gem 'dry-monads'
gem 'dry-transaction'
# gem 'dry-validation', '~> 0.13.3'

# DOMAIN LAYER
gem 'dry-struct'
gem 'dry-types'

# INFRASTRUCTURE LAYER
# Networking
gem 'http'

# Queues
gem 'aws-sdk-sqs'

# Database
gem 'hirb'
gem 'sequel'

# Ruby AST unparser
gem 'unparser'

# Git Operation by using git object
gem 'git'

# MongoDB Driver
gem 'mongo'

# QUALITY
gem 'flog'
gem 'rubocop'
gem 'rubocop-performance'

group :development, :test do
  gem 'database_cleaner'
  gem 'factory_bot'
  gem 'reek'
  gem 'sqlite3'
end

group :production do
  gem 'pg'
end

# WORKERS
gem 'faye'
gem 'shoryuken'

# DEBUGGING
group :development, :test do
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
end

# TESTING
group :test do
  gem 'minitest'
  gem 'minitest-hooks'
  gem 'minitest-rg'
  gem 'simplecov'
  gem 'vcr'
  gem 'webmock'
end

gem 'rack-test' # can also be used to diagnose production

# UTILITIES
gem 'pry'
gem 'rake'
gem 'travis'

group :development, :test do
  gem 'rerun'
end
