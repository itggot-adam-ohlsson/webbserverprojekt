require_relative 'model.rb'

class Booking < Model

  attr_reader :userId, :movieId

  @model_name = itself.to_s.downcase
  @model = itself
  @modelsById = Hash.new

  def initialize(id)
    super(id)
  end

  def self.get(id)
    booking = get_or_initialize(id)
    db = SQLite3::Database.open('db/LoginSystem.sqlite')
    dbresult = db.execute('SELECT * FROM bookings WHERE id = ?', id).first
    booking.userId = dbresult[1]
    booking.movieId = dbresult[2]
    return booking
  end

  def userId=(userId)
    @userId = userId
  end

  def movieId=(movieId)
    @movieId = movieId
  end

end
