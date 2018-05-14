require_relative 'model.rb'

class Seat < Model

  ATTRS = [:bookingId, :seatNr]
  attr_accessor(*ATTRS)

  @model = itself
  @modelsById = Hash.new

  def initialize(id)
    super(id)
  end

end
