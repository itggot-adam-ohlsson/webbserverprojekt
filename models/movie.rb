require_relative 'model.rb'

class Movie < Model

  ATTRS = [:name, :genre, :duration, :seats, :img]
  attr_accessor(*ATTRS)

end
