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

  # def method_missing(method, *args)
  #   result = []
  #   if method.to_s.end_with?"s"
  #     db = SQLite3::Database.open('db/LoginSystem.sqlite')
  #     seats = db.execute("SELECT * FROM #{method} WHERE #{@model_name}_id")
  #     seats.each do |seat|
  #       result << Seat.get_or_initialize(seat[0])
  #     end
  #   end
  #   result
  # end

end
