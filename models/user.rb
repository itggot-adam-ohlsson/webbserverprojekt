require_relative 'model.rb'

class User < Model

  attr_reader :name

  def initialize(id, name, password)
    @id = id
    @name = name
    @password = password
  end

  def self.get(id)
    db = SQLite3::Database.open('db/LoginSystem.sqlite')
    dbresult = db.execute('SELECT * FROM users WHERE id = ?', id).first
    User.new(id, dbresult[1], dbresult[2])
  end

end
