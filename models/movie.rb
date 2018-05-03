require_relative 'model.rb'

class Movie < Model

  ATTRS = [:name, :genre, :duration, :seats, :img]
  attr_accessor(*ATTRS)

  @model_name = itself.to_s.downcase
  @model = itself
  @modelsById = Hash.new
  @seats = :booking

  def initialize(id)
    super(id)
  end
end
