class SFBio < Sinatra::Base

  #enable :sessions
  register Sinatra::Flash
  use Rack::Session::Cookie, :key=> 'rack.session'

  attr_reader :db

  before do
    @db = ConnectionPool.instance.obtain

    if !['register', 'authentication', nil].include?(request.path_info.split('/')[1]) && !session[:user]
      redirect "/"
    end
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

  get '/registered' do
    slim :'register/registered'
  end

  get '/logout' do
    redirect_path = User.get(@db, session[:user]).logout(self)
    redirect redirect_path
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
    return redirect "/movies" if params["seats"] == nil
    booking = Booking.create(@db, {"userId" => session[:user], "movieId" => params["id"]})
    params["seats"].each do |seatNr|
      Seat.create(@db, "bookingId" => booking.id, "seatNr" => seatNr)
    end
    flash[:notify] = "Thanks for booking #{booking.user.username}!"
    redirect "/bookings/#{booking.id}"
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
