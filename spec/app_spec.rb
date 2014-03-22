require_relative 'spec_helper'
require_relative '../boot'
require 'rack/test'

def app
  @app ||= PocketTaggerApp.new
end

describe PocketTaggerApp do
  include Rack::Test::Methods

  describe "/" do
    it "works" do
      get "/"
      last_response.status.must_equal 200
    end

    it "has a link to connect to Pocket oauth" do
      get "/"
      last_response.body.must_include "/oauth/connect"
    end
  end

  describe '/oauth/connect' do
    it "stores the Pocket code in the session" do
      uri = "http://pocket-tagger.dev/oauth/callback"
      Pocket.expects(:get_code).with({ redirect_uri: uri }).
        returns("pocket_code")

      get '/oauth/connect'

      last_request.session[:code].must_equal "pocket_code"
    end

    it "redirects to Pocket for authorization" do
      Pocket.stubs(:get_code).returns("pocket_code")
      get '/oauth/connect'
      last_response.status.must_equal 302
      pocket_auth_url = %r{\Ahttps://getpocket\.com/auth/authorize}
      last_response.location.must_match pocket_auth_url
    end
  end

  describe '/oauth/callback' do
    it 'asks Pocket for the access token and stores it in the session' do
      Pocket.expects(:get_access_token).with("received_code").
        returns("pocket_token")
      session = { code: "received_code" }
      get '/oauth/callback', {}, { 'rack.session' => session }
      last_request.session[:access_token].must_equal "pocket_token"
    end
  end

  describe '/logout' do
    it 'clears the session' do
      get '/logout', {}, { 'rack.session' => { foo: "bar" } }
      last_request.session[:foo].must_be_nil
    end
  end
end
