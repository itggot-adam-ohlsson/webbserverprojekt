class Model
  attr_reader :id

  #@model_name = nil

  def initialize(id)
    @id = id
  end

  def self.get_or_initialize(id)
    if @modelsById.include? id
      @modelsById[id]
    else
      @modelsById[id] = @model.new(id)
    end
  end

  def self.create(items)
    db = SQLite3::Database.open('db/LoginSystem.sqlite')
    dbresult = db.execute('INSERT INTO "main"."movies" ("name","genre","duration","seats") VALUES (?,?,?,?)', [name, genre, duration, seats])
  end

  def method_missing(method, *args)
    result = []
    if method.to_s.end_with?"s"
      db = SQLite3::Database.open('db/LoginSystem.sqlite')
      seats = db.execute("SELECT * FROM #{method} WHERE #{itself.class.to_s.downcase}Id = ?", @id)
      seats.each do |seat|
        result << Seat.get(seat[0])
      end
    end
    result
  end

end
