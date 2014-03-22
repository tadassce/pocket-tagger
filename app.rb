class PocketTaggerApp < Sinatra::Base
  use Rack::Flash
  enable :sessions

  get '/' do
    if authenticated?
      get_items
      erb :pocket
    else
      erb :index
    end
  end

  get "/oauth/connect" do
    store_pocket_code
    redirect pocket_auth_url
  end

  get "/oauth/callback" do
    authenticate
    redirect "/"
  end

  get '/logout' do
    logout
    redirect '/'
  end

  private

  def callback_url
    "http://pocket-tagger.dev/oauth/callback"
  end

  def store_pocket_code
    session[:code] = Pocket.get_code(redirect_uri: callback_url)
  end

  def pocket_auth_url
    Pocket.authorize_url(code: session[:code], redirect_uri: callback_url)
  end

  def authenticated?
    session[:access_token]
  end

  def authenticate
    if session[:code]
      session[:access_token] = Pocket.get_access_token(session[:code])
      flash[:notice] = "Authenticated!"
    else
      flash[:error] = "Wah wah wahhhh…"
    end
  end

  def logout
    session.clear
    flash[:notice] = "Logged out"
  end

  def client
    Pocket.client(access_token: session[:access_token])
  end

  def get_items
    @items = client.retrieve(detailType: :complete)
  end
end
