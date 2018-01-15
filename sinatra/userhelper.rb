require 'sinatra/base'

module Sinatra
  module ProfileHelper

    def profile_route
      puts session[:user]
      if session[:user]
        @username = User.get(session[:user]).name
        slim :'user/profile'
      else
        redirect "/"
      end
    end

    def password_change_route
      if session[:user]
        slim :'user/change'
      else
        redirect "/"
      end
    end

    def password_changed_route
      if session[:user]
        db = SQLite3::Database.open('db/LoginSystem.sqlite')
        slim :'user/change'

        old_password = params["old_password"]
        new_password = params["new_password"]

        unless old_password.length > 0 && new_password.length > 0
          redirect "/"
        end

        dbresult = db.execute('SELECT * FROM users WHERE id = ?', session[:user]).first
        p dbresult
        unless dbresult == nil
          dbhash = dbresult[2]
          passwordhash = BCrypt::Password.new(dbhash)

          if passwordhash == old_password
            passwordhash = BCrypt::Password.create(new_password)
            db.execute('UPDATE users SET password = ? WHERE id = ?', [passwordhash, session[:user]])
            session.destroy
            redirect "/"
          else
            redirect "/profile"
          end
        end
      else
        redirect "/"
      end
    end

  end
  helpers UserHelper
end
