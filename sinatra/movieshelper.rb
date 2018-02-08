require 'sinatra/base'

module Sinatra
  module MoviesHelper

    def movies_route
      if session[:user]
        db = SQLite3::Database.open('db/LoginSystem.sqlite')

        @movies = db.execute('SELECT * FROM movies')
        slim :'sfbio/movies'
      else
        redirect "/"
      end
    end

    def tickets_route
      if session[:user]
        movie_id = params["id"]

        db = SQLite3::Database.open('db/LoginSystem.sqlite')

        @movie = db.execute('SELECT name FROM movies WHERE id = ?', movie_id)
        slim :'sfbio/movie'
      else
        redirect "/"
      end
    end

  end
  helpers MoviesHelper
end
