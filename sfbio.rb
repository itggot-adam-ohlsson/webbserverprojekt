class SFBio < Sinatra::Base

  #enable :sessions
  use Rack::Session::Cookie, :key=> 'rack.session'

  attr_reader :db

  before do
    @db = ConnectionPool.instance.obtain
  end

  get '/' do
    slim :'login/index'
  end

  get '/logout' do
    redirect_path = User.get(@db, session[:user]).logout(self)
    redirect redirect_path
  end

  post '/authentication' do
    redirect_path = User.authentication(self, params["username"], params["password"])
    redirect redirect_path
  end

  get '/register' do
    slim :'register/register'
  end

  post '/register' do
    redirect_path = User.register(@db, params["username"], params["password"])
    redirect redirect_path
  end

  get '/registered' do
    slim :'register/registered'
  end

  get '/profile' do
    @username = User.get(@db, session[:user]).username
    slim :'user/profile'
  end

  get '/change' do
    slim :'user/change'
  end

  post '/changed' do
    redirect_path = User.get(@db, session[:user]).changedPassword(self, params["old_password"], params["new_password"])
    redirect redirect_path
  end

  get '/movies' do
    @movies = Movie.get_all(@db)
    slim :'sfbio/movies'
  end

  get '/movies/:id' do
    @movie = Movie.get(@db, params["id"])
    @booked = Seat.count_through(@db, Booking, @movie)
    slim :'sfbio/movie'
  end

  get '/movies/:id/tickets' do
    @movie = Movie.get(@db, params["id"])
    @seats = Seat.get_through(@db, Booking, @movie)
    @booked = @seats.map{|seat| seat.seatNr}
    slim :'sfbio/tickets'
  end

  post '/movies/:id/tickets/seats' do
    booking = Booking.create(@db, {"userId" => session[:user], "movieId" => params["id"], "timestamp" => DateTime.now.to_s})
    if params["seats"] == nil
      redirect "/movies"
    end
    params["seats"].each do |seatNr|
      Seat.create(@db, "bookingId" => booking.id, "seatNr" => seatNr)
    end
    redirect "/movies/#{booking.movieId}/tickets/#{booking.id}"
  end

  get '/movies/:id/tickets/:bookingId' do
    @booking = Booking.get(@db, params["bookingId"])
    @seats = @booking.seats.map{|seat|seat.seatNr}
    @timestamp = DateTime.parse(@booking.timestamp).strftime('%Y-%m-%d %H:%M:%S')
    slim :'sfbio/seats'
  end

  get '/bookings' do
    @user = User.get(@db, session[:user])
    @bookings = @user.bookings
    slim :'user/bookings'
  end

  get '/bookings/:id' do
    @booking = Booking.get(@db, params["id"])
    @seats = @booking.seats.map{|seat|seat.seatNr}
    @timestamp = DateTime.parse(@booking.timestamp).strftime('%Y-%m-%d %H:%M:%S')
    slim :'user/booking'
  end

  after do
    ConnectionPool.instance.release(@db)
  end
end
