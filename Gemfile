# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Configuration and Utilities
gem 'figaro', '~> 1.2'
gem 'rack', '~> 2'
gem 'rack-test'
gem 'rake', '~> 13.0'

# Caching
gem 'rack-cache', '~> 1.13'
gem 'redis', '~> 4.5'
gem 'redis-rack-cache', '~> 2.2'

# PRESENTATION LAYER
gem 'multi_json', '~> 1.15'
gem 'roar', '~> 1.1'

# Application Layer
# Web Application
gem 'puma', '~> 5.5'
gem 'roda', '~> 3.49'
gem 'slim', '~> 4.1'

# Controllers and services
gem 'dry-monads', '~> 1.4'
gem 'dry-transaction', '~> 0.13'
gem 'dry-validation', '~> 1.7'

# Domain Layer
# Validation
gem 'dry-struct', '~> 1.4'
gem 'dry-types', '~> 1.5'

# Networking
gem 'http', '~> 5.0'

# Tools
gem 'crack'

# Asynchronicity

gem 'aws-sdk-sqs', '~> 1.48'
gem 'concurrent-ruby', '~> 1.1'
gem 'shoryuken', '~> 5.3'

# Database
gem 'sequel', '~> 5.49'

group :development, :test do
  gem 'sqlite3', '~> 1.4'
end

group :production do
  gem 'pg', '~> 1.2'
end

# Testing
group :test do
  gem 'minitest', '~> 5.0'
  gem 'minitest-rg', '~> 5.0'
  gem 'simplecov', '~> 0'
  gem 'vcr', '~> 6.0'
  gem 'webmock', '~> 3.0'

  gem 'headless', '~> 2.3'
  gem 'page-object', '~> 2.3'
  gem 'watir', '~> 7.0'
  gem 'webdrivers', '~> 5.0'
end

group :development do
  gem 'rerun', '~> 0'
end

# Debugging
gem 'pry'

# Code Quality
group :development do
  gem 'flog'
  gem 'reek'
  gem 'rubocop'
end
