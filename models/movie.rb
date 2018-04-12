require_relative 'model.rb'

class Movie < Model

  attr_accessor :name, :genre, :duration, :seats, :img

  @model_name = itself.to_s.downcase
  @model = itself
  @modelsById = Hash.new

  def initialize(id)
    super(id)
  end
end
