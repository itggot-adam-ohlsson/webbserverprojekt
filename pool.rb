require 'singleton'
require 'thread'

class ConnectionPool
  include Singleton

  def initialize
    @pool = Queue.new
  end

  def create(pool_size, &block)
    object_contruction = block.to_proc
    pool_size.times do
      @pool << object_contruction.call
    end
  end

  def obtain
    puts @pool.length
    @pool.pop
  end

  def release(object)
    puts object.inspect
    @pool << object
  end
end
