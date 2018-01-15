require_relative 'model.rb'

class User < Model

  attr_reader :name

  def initialize(id)
    super(id, itself)
  end

  def self.get(id)
    user = get_or_initialize(id)
    db = SQLite3::Database.open('db/LoginSystem.sqlite')
    dbresult = db.execute('SELECT * FROM users WHERE id = ?', id).first
    user.name = dbresult[1]
    user.password = dbresult[2]
    return user
  end

  private

  def name=(name)
    @name = name
  end

  def password=(password)
    @password = password
  end

end
