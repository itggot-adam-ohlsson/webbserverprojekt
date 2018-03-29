require_relative 'model.rb'

class User < Model

  attr_reader :name

  @model_name = itself.to_s.downcase
  @model = itself
  @modelsById = Hash.new

  def initialize(id)
    super(id)
  end

  def self.get(id)
    user = get_or_initialize(id)
    db = SQLite3::Database.open('db/LoginSystem.sqlite')
    dbresult = db.execute('SELECT * FROM users WHERE id = ?', id).first
    user.name = dbresult[1]
    user.password = dbresult[2]
    return user
  end

  def changedPassword(ctx, old_password, new_password)
    db = SQLite3::Database.open('db/LoginSystem.sqlite')

    if old_password.length < 0 || new_password.length < 0
      return "/"
    end

    dbresult = db.execute('SELECT * FROM users WHERE id = ?', @id).first
    unless dbresult == nil
      dbhash = dbresult[2]
      passwordhash = BCrypt::Password.new(dbhash)
      if passwordhash == old_password
        passwordhash = BCrypt::Password.create(new_password)
        db.execute('UPDATE users SET password = ? WHERE id = ?', [passwordhash, @id])
        ctx.session.destroy
        return "/"
      else
        return "/profile"
      end
    end
  end

  def self.register(username, password)
    db = SQLite3::Database.open('db/LoginSystem.sqlite')

    unless username.length > 0 && password.length > 0
      return "/register"
    end

    passwordhash = BCrypt::Password.create(password)
    dbresult = db.execute('SELECT * FROM users WHERE username = ?', username)

    if dbresult.length > 0
      return "/register"
    end

    db.execute('INSERT INTO "main"."users" ("username","password") VALUES (?,?)', [username, passwordhash])
    return "/"
  end

  def self.authentication(ctx, username, password)
    db = SQLite3::Database.open('db/LoginSystem.sqlite')

    unless username.length > 0 && password.length > 0
      return "/"
    end

    dbresult = db.execute('SELECT * FROM users WHERE username = ?', username).first
    unless dbresult == nil
      dbhash = dbresult[2]
      passwordhash = BCrypt::Password.new(dbhash)

      if passwordhash == password
        ctx.session[:user] = dbresult[0]
        return "/profile"
      end
    end
    return "/"
  end

  def logout(ctx)
    ctx.session.destroy
    return "/"
  end

  def name=(name)
    @name = name
  end

  def password=(password)
    @password = password
  end

end
