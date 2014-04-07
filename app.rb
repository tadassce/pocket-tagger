class PocketTaggerApp < Sinatra::Base
  use Rack::Flash
  enable :sessions

  before do
    public_paths = [
      '/',
      '/oauth/connect',
      '/oauth/callback',
      '/logout'
    ]
    if !authenticated? && !public_paths.include?(request.path_info)
      flash[:error] = 'Please authenticate'
      redirect '/'
    end
  end

  get '/' do
    if authenticated?
      redirect '/tag'
    else
      slim :index
    end
  end

  get '/tag' do
    slim :tag
  end

  post '/tag' do
    token = session[:access_token]
    speed = params[:reading_speed]

    items_tagged = PocketTagger.new(token, speed).tag!

    if items_tagged.to_i > 0
      flash[:notice] = "Success! #{items_tagged} items were tagged."
    elsif items_tagged == 0
      flash[:notice] = "Hm, we haven't found any items to tag this time"
    else
      flash[:error] = 'Something went wrong.'
    end
    slim :tag
  end

  get '/oauth/connect' do
    store_pocket_code
    redirect pocket_auth_url
  end

  get '/oauth/callback' do
    authenticate
    redirect '/tag'
  end

  get '/logout' do
    logout
    redirect '/'
  end

  private

  def callback_uri
    {
      development: 'http://pocket-tagger.dev/oauth/callback',
      test:        'http://pocket-tagger.dev/oauth/callback',
      production:  'TODO'
    }.fetch(settings.environment)
  end

  def store_pocket_code
    session[:code] = Pocket.get_code(redirect_uri: callback_uri)
  end

  def pocket_auth_url
    Pocket.authorize_url(code: session[:code], redirect_uri: callback_uri)
  end

  def authenticated?
    session[:access_token]
  end

  def authenticate
    code = session[:code]
    if code
      session[:access_token] = Pocket.get_access_token(code)
      flash[:notice] = 'Authenticated!'
    end
  end

  def logout
    session.clear
    flash[:notice] = 'Logged out'
  end
end
