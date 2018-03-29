require_relative 'model.rb'

class Seat < Model

  attr_reader :bookingId, :seatNr

  @model_name = itself.to_s.downcase
  @model = itself
  @modelsById = Hash.new

  def initialize(id)
    super(id)
  end

  def self.get(id)
    seat = get_or_initialize(id)
    db = SQLite3::Database.open('db/LoginSystem.sqlite')
    dbresult = db.execute('SELECT * FROM seats WHERE id = ?', id).first
    seat.bookingId = dbresult[1]
    seat.seatNr = dbresult[2]
    return seat
  end

  def self.create(bookingId, movieId, seatNr)
    db = SQLite3::Database.open('db/LoginSystem.sqlite')
    db.execute('INSERT INTO "main"."seats" ("bookingId","seatNr") VALUES (?,?)', [bookingId, seatNr])

    id = db.execute('SELECT last_insert_rowid();').first.first
    self.get(id)
  end

  def bookingId=(bookingId)
    @bookingId = bookingId
  end

  def seatNr=(seatNr)
    @seatNr = seatNr
  end

end
