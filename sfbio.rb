class SFBio < Sinatra::Base

  enable :sessions
  #use Rack::Session::Cookie, :key=> 'rack.session'

  attr_reader :db

  before do
    @db = ConnectionPool.instance.obtain
  end

  get '/' do
    slim :'login/index'
  end

  get '/register' do
    slim :'register/register'
  end

  post '/authentication' do
    redirect_path = User.authentication(self, params["username"], params["password"])
    redirect redirect_path
  end

  post '/register' do
    redirect_path = User.register(@db, params["username"], params["password"])
    redirect redirect_path
  end

  #make secured

  get '/registered' do
    if session[:user]
      slim :'register/registered'
    else
      redirect "/"
    end
  end

  get '/logout' do
    if session[:user]
      redirect_path = User.get(@db, session[:user]).logout(self)
      redirect redirect_path
    else
      redirect "/"
    end
  end

  get '/profile' do
    if session[:user]
      @username = User.get(@db, session[:user]).username
      slim :'user/profile'
    else
      redirect "/"
    end
  end

  get '/change' do
    if session[:user]
      slim :'user/change'
    else
      redirect "/"
    end
  end

  post '/changed' do
    redirect_path = User.get(@db, session[:user]).changedPassword(self, params["old_password"], params["new_password"])
    redirect redirect_path
  end

  get '/movies' do
    if session[:user]
      @movies = Movie.get_all(@db)
      slim :'sfbio/movies'
    else
      redirect "/"
    end
  end

  get '/movies/:id' do
    if session[:user]
      @movie = Movie.get(@db, params["id"])
      @booked = Seat.count_through(@db, Booking, @movie)
      slim :'sfbio/movie'
    else
      redirect "/"
    end
  end

  get '/movies/:id/tickets' do
    if session[:user]
      @movie = Movie.get(@db, params["id"])
      @seats = Seat.get_through(@db, Booking, @movie)
      @booked = @seats.map{|seat| seat.seatNr}
      slim :'sfbio/tickets'
    else
      redirect "/"
    end
  end

  post '/movies/:id/tickets/seats' do
    booking = Booking.create(@db, {"userId" => session[:user], "movieId" => params["id"], "timestamp" => DateTime.now.to_s})
    return redirect "/movies" if params["seats"] == nil
    params["seats"].each do |seatNr|
      Seat.create(@db, "bookingId" => booking.id, "seatNr" => seatNr)
    end
    redirect "/movies/#{booking.movieId}/tickets/#{booking.id}"
  end

  get '/movies/:id/tickets/:bookingId' do
    if session[:user]
      @booking = Booking.get(@db, params["bookingId"])
      @seats = @booking.seats.map{|seat|seat.seatNr}
      @timestamp = DateTime.parse(@booking.timestamp).strftime('%Y-%m-%d %H:%M:%S')
      slim :'sfbio/seats'
    else
      redirect "/"
    end
  end

  get '/bookings' do
    if session[:user]
      @user = User.get(@db, session[:user])
      @bookings = @user.bookings
      slim :'user/bookings'
    else
      redirect "/"
    end
  end

  get '/bookings/:id' do
    if session[:user]
      @booking = Booking.get(@db, params["id"])
      @seats = @booking.seats.map{|seat|seat.seatNr}
      @timestamp = DateTime.parse(@booking.timestamp).strftime('%Y-%m-%d %H:%M:%S')
      slim :'user/booking'
    else
      redirect "/"
    end
  end

  after do
    ConnectionPool.instance.release(@db)
  end
end
