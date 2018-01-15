require 'sinatra/base'

module Sinatra
  module RegisterHelper

    def register_route(params)
      db = SQLite3::Database.open('db/LoginSystem.sqlite')
      username = params['username']
      password = params['password']

      unless username.length > 0 && password.length > 0
        redirect "/"
      end
      passwordhash = BCrypt::Password.create(password)

      dbresult = db.execute('SELECT * FROM users WHERE username = ?', username)
      puts dbresult.length
      if dbresult.length > 0
        redirect "/"
      end

      db.execute('INSERT INTO "main"."users" ("username","password") VALUES (?,?)', [username, passwordhash])
      redirect "/registered"
    end

  end

  helpers RegisterHelper
end
