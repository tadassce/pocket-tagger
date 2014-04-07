ENV['RACK_ENV'] = 'test'

if ENV['COV']
  require 'simplecov'
  SimpleCov.start
end

Bundler.require(:test)

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
end
