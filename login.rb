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
    @movies = Movie.getAll(@db)
    slim :'sfbio/movies'
  end

  get '/movies/:id' do
    @movie = Movie.get(@db, params["id"])
    slim :'sfbio/movie'
  end

  get '/movies/:id/tickets' do
    @booked = []
    @movie = Movie.get(@db, params["id"])
    dbresult = @db.execute("SELECT SeatNr FROM seats WHERE bookingId IN (SELECT id FROM bookings WHERE movieId = ?)", params["id"])
    dbresult.each do |element|
    @booked << element.values.first
    end
    @movie = Movie.get(@db, params["id"])
    @movie.seats

    slim :'sfbio/tickets'
  end

  post '/movies/:id/tickets/seats' do
    booking = Booking.create(@db, {"userId" => session[:user], "movieId" => params["id"], "timestamp" => DateTime.now.to_s})
    params["seats"].each do |seatNr|
      Seat.create(@db, "bookingId" => booking.id, "seatNr" => seatNr)
    end
    redirect "/movies/#{booking.movieId}/tickets/#{booking.id}"
  end

  get '/movies/:id/tickets/:bookingId' do
    @username = User.get(@db, session[:user]).username
    @movie = Movie.get(@db, params["id"])
    @booking = Booking.get(@db, params["bookingId"])
    @seats = []
    @booking.seats.each do |seat|
      @seats << seat.seatNr
    end
    timestamp = DateTime.parse(@booking.timestamp)
    @timestamp = timestamp.strftime('%Y-%m-%d %H:%M:%S')
    slim :'sfbio/seats'
  end

  get '/bookings' do
    @user = User.get(@db, session[:user])
    @bookings = @user.bookings
    puts @bookings[0].user.to_s
    slim :'user/bookings'
  end

  get '/bookings/:id' do
    id = params["id"]
    @booking = Booking.get(@db, params["id"])
    @movie = Movie.get(@db, @booking.movieId)
    @seats = []
    @booking.seats.each do |seat|
      @seats << seat.seatNr
    end
    timestamp = DateTime.parse(@booking.timestamp)
    @timestamp = timestamp.strftime('%Y-%m-%d %H:%M:%S')
    slim :'user/booking'
  end

  after do
    ConnectionPool.instance.release(@db)
  end
end
