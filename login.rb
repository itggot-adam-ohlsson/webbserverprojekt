class SFBio < Sinatra::Base

  helpers Sinatra::LoginHelper, Sinatra::RegisterHelper, Sinatra::UserHelper

  enable :sessions

  get '/' do
    db = SQLite3::Database.open('db/LoginSystem.sqlite')
    slim :'login/index'
  end

  get '/logout' do
    logout_route
  end

  post '/authentication' do
    authentication_route(params)
  end

  post '/register' do
    register_route(params)
  end

  get '/registered' do
    slim :'register/registered'
  end

  get '/profile' do
    profile_route
  end

  get '/change' do
    password_change_route
  end

  post '/changed' do
    password_changed_route
  end
end
