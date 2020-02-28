source 'https://rubygems.org'

ruby '2.2.3'

gem 'sinatra',     '~> 1.4.4'
gem 'pocket-ruby', '~> 0.0.6'
gem 'rack-flash3', '~> 1.0.5', require: 'rack/flash'
gem 'slim',        '~> 2.0.2'
gem 'rake',        '~> 13.0.1'

group :production do
  gem 'unicorn'
end

group :test do
  gem 'minitest',          require: 'minitest/autorun'
  gem 'minitest-colorize', github:  'ysbaddaden/minitest-colorize'
  gem 'rack-test',         require: false
  gem 'webmock',           require: 'webmock/minitest'
  gem 'mocha',             require: 'mocha/mini_test'
  gem 'vcr'
  gem 'simplecov',         require: false
end

group :test, :development do
  gem 'awesome_print'
end
