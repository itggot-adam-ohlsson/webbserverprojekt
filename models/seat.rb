require_relative 'model.rb'

class Seat < Model

  attr_accessor :bookingId, :seatNr

  @model_name = itself.to_s.downcase
  @model = itself
  @modelsById = Hash.new

  def initialize(id)
    super(id)
  end

end
