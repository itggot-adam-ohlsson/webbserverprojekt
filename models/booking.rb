require_relative 'model.rb'

class Booking < Model

  ATTRS = [:userId, :movieId, :timestamp, :movie, :user]
  attr_accessor(*ATTRS)

  @model_name = itself.to_s.downcase
  @model = itself
  @modelsById = Hash.new

  def initialize(id)
    super(id)
  end

end
