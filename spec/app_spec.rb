require_relative 'spec_helper'
require_relative '../boot'
require 'rack/test'

def app
  @app ||= PocketTaggerApp
end

describe PocketTaggerApp do
  include Rack::Test::Methods

  describe "/" do
    it "works" do
      get "/"
      last_response.status.must_equal 200
    end
  end
end
