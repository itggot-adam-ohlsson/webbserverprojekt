class SFBio < Sinatra::Base

  #enable :sessions
  use Rack::Session::Cookie, :key=> 'rack.session'

  attr_reader :db

  before do
    @db = ConnectionPool.instance.obtain
    puts "Obtain" + @db.to_s
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
    redirect_path = User.register(params["username"], params["password"])
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
    puts @db
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
    @movie = Movie.get(@db, params["id"])
    # Håller på att fixa en sak här så listan gör inget ännu egentligen.
    @booked = [1, 4, 5]
    slim :'sfbio/tickets'
  end

  post '/movies/:id/tickets/seats' do
    booking = Booking.create(@db, {"userId" => session[:user], "movieId" => params["id"]})
    seatClass = "booked"
    params["seats"].each do |seatNr|
      Seat.create(@db, "bookingId" => booking.id, "seatNr" => seatNr)
    end
    redirect "/movies/#{booking.movieId}/tickets/#{booking.id}"
  end

  get '/movies/:id/tickets/:bookingId' do
    @movie = Movie.get(@db, params["id"])
    booking = Booking.get_or_initialize(params["bookingId"])
    @seats = []
    booking.seats.each do |seat|
      @seats << seat.seatNr
    end
    slim :'sfbio/seats'
  end

  after do
    ConnectionPool.instance.release(@db)
    puts "Release" + @db.to_s
  end
end
