ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.setup(ENV['RACK_ENV'])
Bundler.require
require_relative 'config/pocket'
require_relative 'app'
