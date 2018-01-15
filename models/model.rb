class Model
  attr_reader :id

  def initialize(id, model)
    @id = id
    @model = model
    @modelsById = Hash.new
  end

  def get_or_initialize(id)
    if @modelsById.include? id
      @modelsById[id]
    else
      model.new(id)
    end
  end

end
