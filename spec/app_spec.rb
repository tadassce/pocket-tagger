require_relative 'spec_helper'
require_relative '../boot'
require 'rack/test'

def app
  @app ||= PocketTaggerApp.new
end

describe PocketTaggerApp do
  include Rack::Test::Methods

  describe '/' do
    it 'works' do
      get '/'
      last_response.status.must_equal 200
    end

    it 'has a link to connect to Pocket oauth' do
      get '/'
      last_response.body.must_include '/oauth/connect'
    end

    it 'redirects to /tag if authenticated' do
      get '/', {}, 'rack.session' => { access_token: 'bar' }
      last_response.status.must_equal 302
      last_response.location.must_equal 'http://example.org/tag'
    end
  end

  describe '/oauth/connect' do
    before do
      VCR.use_cassette('oauth_get_code') do
        get '/oauth/connect'
      end
    end

    it 'stores the Pocket code in the session' do
      last_request.session[:code].wont_be_nil
    end

    it 'redirects to Pocket for authorization' do
      last_response.status.must_equal 302
      pocket_auth_url = %r{\Ahttps://getpocket\.com/auth/authorize}
      last_response.location.must_match pocket_auth_url
    end
  end

  describe '/oauth/callback' do
    it 'asks Pocket for the access token and stores it in the session' do
      VCR.use_cassette('oauth_get_token') do
        c = '<Insert code here>'
        get '/oauth/callback', {}, 'rack.session' => { code: c }
      end
      last_request.session[:access_token].wont_be_nil
    end
  end

  describe '/logout' do
    it 'clears the session' do
      get '/logout', {}, 'rack.session' => { foo: 'bar' }
      last_request.session[:foo].must_be_nil
    end
  end

  describe '/tag' do
    describe 'when not authenticated' do
      before do
        get '/tag'
      end

      it 'redirects to /' do
        last_response.status.must_equal 302
        last_response.location.must_equal 'http://example.org/'
      end

      it 'shows a flash error message on the front page after redirect' do
        follow_redirect!
        last_response.body.must_include 'Please authenticate'
      end
    end

    describe 'when authenticated' do
      it 'has the form' do
        get '/tag', {}, 'rack.session' => { access_token: 'foo' }
        last_response.body.must_include '<form'
      end
    end
  end

  describe 'POST /tag' do
    it 'sends the tag! message to the PocketTagger' do
      PocketTagger.any_instance.expects(:tag!).once
      post '/tag', {}, 'rack.session' => { access_token: 'foo' }
    end

    it 'shows the number of items that were tagged' do
      PocketTagger.any_instance.stubs(:tag!).returns(3)
      post '/tag', {}, 'rack.session' => { access_token: 'foo' }
      last_response.body.must_include '3 items were tagged'
    end

    it 'tells the user if there was nothing to tag' do
      PocketTagger.any_instance.stubs(:tag!).returns(0)
      post '/tag', {}, 'rack.session' => { access_token: 'foo' }
      last_response.body.must_include 'any items to tag'
    end

    it 'shows an error message if failed' do
      PocketTagger.any_instance.expects(:tag!)
      post '/tag', {}, 'rack.session' => { access_token: 'foo' }
      last_response.body.must_include 'Something went wrong'
    end
  end
end
