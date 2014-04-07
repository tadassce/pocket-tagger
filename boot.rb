ENV['RACK_ENV'] ||= 'development'

require 'bundler/setup'
Bundler.setup
Bundler.require(:default, ENV['RACK_ENV'])
require_relative 'lib/pocket_tagger'
require_relative 'app'
