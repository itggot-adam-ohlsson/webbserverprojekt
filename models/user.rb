require_relative 'model.rb'

class User < Model

  attr_accessor :username, :password

  @model_name = itself.to_s.downcase
  @model = itself
  @modelsById = Hash.new

  def initialize(id)
    super(id)
  end

  def changedPassword(ctx, old_password, new_password)

    if old_password.length < 0 || new_password.length < 0
      return "/"
    end

    passwordhash = BCrypt::Password.new(@password)
    if passwordhash == old_password
      passwordhash = BCrypt::Password.create(new_password)
      update(ctx.db, "password" => passwordhash)
      ctx.session.destroy
      return "/"
    end
  end

  def self.register(username, password)

    unless username.length > 0 && password.length > 0
      return "/register"
    end

    passwordhash = BCrypt::Password.create(password)

    users = get_by_username(username)
    if users.any?
      return "/register"
    end

    self.create("username" => username, "password" => passwordhash)
    return "/"
  end

  def self.authentication(ctx, username, password)

    unless username.length > 0 && password.length > 0
      return "/"
    end

    users = User.get_by_username(ctx.db, username)
    if users.any?
      dbhash = users.first.password
      passwordhash = BCrypt::Password.new(dbhash)

      if passwordhash == password
        ctx.session[:user] = users.first.id
        return "/profile"
      end
    end
    return "/"
  end

  def logout(ctx)
    ctx.session.destroy
    return "/"
  end

end
