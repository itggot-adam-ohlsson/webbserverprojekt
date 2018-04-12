require_relative 'model.rb'

class Booking < Model

  attr_accessor :userId, :movieId

  @model_name = itself.to_s.downcase
  @model = itself
  @modelsById = Hash.new

  def initialize(id)
    super(id)
  end

end
