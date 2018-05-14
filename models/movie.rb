require_relative 'model.rb'

class Movie < Model

  ATTRS = [:name, :genre, :duration, :seats, :img]
  attr_accessor(*ATTRS)

  @model = itself
  @modelsById = Hash.new

  def initialize(id)
    super(id)
  end
end
