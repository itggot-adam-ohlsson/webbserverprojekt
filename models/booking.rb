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

  def self.create(userId, movieId)
    db = SQLite3::Database.open('db/LoginSystem.sqlite')
    db.execute('INSERT INTO "main"."bookings" ("userId","movieId") VALUES (?,?)', [userId, movieId])
    id = db.execute('SELECT last_insert_rowid();').first.first
    self.get(id)
  end

  def userId=(userId)
    @userId = userId
  end

  def movieId=(movieId)
    @movieId = movieId
  end

  def method_missing(method, *args)
    result = []
    if method.to_s.end_with?"s"
      db = SQLite3::Database.open('db/LoginSystem.sqlite')
      seats = db.execute("SELECT * FROM #{method} WHERE #{self.class.to_s.downcase}Id = ?", @id)
      puts seats
      seats.each do |seat|
        result << Seat.get(seat[0])
      end
    end
    result
  end

end
