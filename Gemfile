source 'https://rubygems.org'

ruby '2.1.7'

gem 'sinatra',     '~> 1.4.4'
gem 'pocket-ruby', '~> 0.0.5', require: 'pocket'
gem 'rack-flash3', '~> 1.0.5', require: 'rack/flash'
gem 'slim',        '~> 2.0.2'
gem 'rake',        '~> 10.2.2'

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

group :development do
  gem 'guard-minitest', require: false
  gem 'guard-pow',      require: false
end
