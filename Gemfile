# frozen_string_literal: true

source 'https://rubygems.org'
# source 'http://mirror.ops.rhcloud.com/mirror/ruby/'
ruby '2.5.5'

# PRESENTATION LAYER
gem 'multi_json', '~> 1.13', '>= 1.13.1'
gem 'roar', '~> 1.1'

# APPLICATION LAYER
# Web application related
gem 'econfig', '~> 2.1'
gem 'puma', '~> 3.11'
gem 'rack-cache', '~> 1.8'
gem 'redis', '~> 4.0'
gem 'redis-rack-cache', '~> 2.0'
gem 'roda', '~> 3.8'

# Controllers and services
gem 'dry-monads', '~> 1.1'
gem 'dry-transaction', '~> 0.13.0'
# gem 'dry-validation', '~> 0.13.3'

# DOMAIN LAYER
gem 'dry-struct', '~> 1.0'
gem 'dry-types', '~> 1.0'

# INFRASTRUCTURE LAYER
# Networking
gem 'http', '~> 3.0'

# Queues
gem 'aws-sdk-sqs', '~> 1'

# Database
gem 'hirb', '~> 0.7'
gem 'sequel', '~> 5.13'

# Ruby AST unparser
gem 'unparser', '~> 0.4.5'

# Git Operation by using git object
gem 'git', '~> 1.5'

# MongoDB Driver
gem 'mongo', '~> 2.8'


# QUALITY
gem 'flog', '~> 4.6', '>= 4.6.2'
gem 'rubocop', '~> 0.70.0'

group :development, :test do
  gem 'database_cleaner', '~> 1.7'
  gem 'sqlite3', '~> 1.4', '>= 1.4.1'
  gem 'factory_bot', '~> 5.0', '>= 5.0.2'
  gem 'reek'
end

group :production do
  gem 'pg', '~> 0.18'
end

# WORKERS
gem 'shoryuken', '~> 4'
gem 'faye', '~> 1'

# DEBUGGING
group :development, :test do
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
end

# TESTING
group :test do
  gem 'minitest', '~> 5.11'
  gem 'minitest-rg', '~> 5.2'
  gem 'minitest-hooks', '~> 1.5'
  gem 'simplecov', '~> 0.16'
  gem 'vcr', '~> 4.0'
  gem 'webmock', '~> 3.4'
end

gem 'rack-test', '~> 1.1' # can also be used to diagnose production


# UTILITIES
gem 'pry'
gem 'rake', '~> 12.3'
gem 'travis'

group :development, :test do
  gem 'rerun'
end
