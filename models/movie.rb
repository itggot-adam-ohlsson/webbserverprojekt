require_relative 'model.rb'

class Movie < Model

  attr_reader :name, :genre, :duration, :seats

  @model_name = itself.to_s.downcase
  @model = itself
  @modelsById = Hash.new

  def initialize(id)
    super(id)
  end

  def self.getAll
    db = SQLite3::Database.open('db/LoginSystem.sqlite')
    dbresult = db.execute('SELECT * FROM movies')
    return dbresult
  end

  def self.get(id)
    movie = get_or_initialize(id)
    db = SQLite3::Database.open('db/LoginSystem.sqlite')
    dbresult = db.execute('SELECT * FROM movies WHERE id = ?', id).first
    movie.name = dbresult[1]
    movie.genre = dbresult[2]
    movie.duration = dbresult[3]
    movie.seats = dbresult[4]
    return movie
  end

  def self.create(name, genre, duration, seats)
    db = SQLite3::Database.open('db/LoginSystem.sqlite')
    dbresult = db.execute('INSERT INTO "main"."movies" ("name","genre","duration","seats") VALUES (?,?,?,?)', [name, genre, duration, seats])
  end

  def name=(name)
    @name = name
  end

  def genre=(genre)
    @genre = genre
  end

  def duration=(duration)
    @duration = duration
  end

  def seats=(seats)
    @seats = seats
  end

end
