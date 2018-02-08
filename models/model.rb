class Model
  attr_reader :id

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

end
