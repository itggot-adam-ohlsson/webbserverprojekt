require_relative 'model.rb'

class Booking < Model

  ATTRS = [:userId, :movieId, :timestamp]
  attr_accessor(*ATTRS)

  @model = itself
  @modelsById = Hash.new

  def initialize(id)
    super(id)
  end

end
