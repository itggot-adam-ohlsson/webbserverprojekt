require 'sinatra/base'

module Sinatra
  module LoginHelper

    def authentication_route(params)
      db = SQLite3::Database.open('db/LoginSystem.sqlite')
      username = params['username']
      password = params['password']

      unless username.length > 0 && password.length > 0
        redirect "/"
      end

      dbresult = db.execute('SELECT * FROM users WHERE username = ?', username).first
      unless dbresult == nil
        dbhash = dbresult[2]
        passwordhash = BCrypt::Password.new(dbhash)

        if passwordhash == password
          session[:user] = dbresult[0]
          redirect "/profile"
        end
      end
      redirect "/"
    end

    def logout_route
      session.destroy
      redirect "/"
    end

  end

  helpers LoginHelper
end
