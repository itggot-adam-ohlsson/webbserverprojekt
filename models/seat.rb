require_relative 'model.rb'

class Seat < Model

  ATTRS = [:bookingId, :seatNr]
  attr_accessor(*ATTRS)

  @model_name = itself.to_s.downcase
  @model = itself
  @modelsById = Hash.new

  def initialize(id)
    super(id)
  end

end
