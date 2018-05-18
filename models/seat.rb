require_relative 'model.rb'

class Seat < Model

  ATTRS = [:bookingId, :seatNr]
  attr_accessor(*ATTRS)

end
