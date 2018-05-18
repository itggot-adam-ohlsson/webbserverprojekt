class Model
  attr_reader :id

  def initialize(id)
    @id = id
  end

  # Denna metoden hämtar/sparar model av id som hör ihop med id.
  def self.get_or_initialize(id)
    @modelsById = @modelsById || Hash.new
    if @modelsById.include? id
      @modelsById[id]
    else
      @modelsById[id] = itself.new(id)
    end
  end

  private
  def self.hash_to_model(dbmodel, items)
    items.keys.length.times do |i|
      writer = items.keys[i].to_s + "="
      if dbmodel.respond_to?(writer) && items.keys[i] != "id"
        dbmodel.send(writer, items.values[i])
      end
    end
    dbmodel
  end

  def self.get_from_model(db, klass, where)
    if where.length > 0
      where_keys = where.keys.map{|key|"#{key} = ?"}.join(" AND ")
      where_clause = " WHERE #{where_keys}"
    else
      where_clause = ""
    end

    get_from_model_where(db, klass, where_clause, where.values)
  end

  def self.get_from_model_where(db, klass, where_clause, where_values)
    model_name = klass.to_s.downcase
    db.results_as_hash = true
    keys = foreign_keys(klass)
    mid = "m.id AS #{model_name}Mid"
    if keys.length > 0
        all_ids = (keys.map{|key|"#{key}s.id AS #{key}Mid"} + [mid]).join(",")
        all_keys = keys.map{|key|"#{key}s"}.join(",")
        all_values = keys.map{|key|"m.#{key}Id = #{key}s.id"}.join(" AND ")
        rows = db.execute("SELECT #{all_ids}, * FROM #{model_name}s m INNER JOIN #{all_keys} ON #{all_values} #{where_clause}", where_values)
    else
        rows = db.execute("SELECT #{mid}, * FROM #{model_name}s m #{where_clause}", where_values)
    end

    return rows, keys
  end

  def self.get_from_keys(row, keys)
    mid = row["#{self.to_s.downcase}Mid"]
    dbmodel = get_or_initialize(mid)
    if keys.length > 0
      keys.each do |key|
        klass = Object.const_get(key.to_s.capitalize)
        dbmodel.class.module_eval { attr_accessor key }
        writer = key.to_s + "="
        dbmodel.send(writer, klass.get_from_keys(row, []))
      end
    end
    hash_to_model(dbmodel, row)
  end

  def self.get_all(db)
    rows, keys = get_from_model(db, self, {})
    rows.map{|row|get_from_keys(row, keys)}
  end

  def self.get(db, id)
    rows, keys = get_from_model(db, self, {"m.id" => id})
    get_from_keys(rows.first, keys)
  end

  def self.get_through(db, klass, model)
    model_name = klass.to_s.downcase
    rows, keys = get_from_model_where(db, self, "WHERE #{model_name}Id IN (SELECT id FROM #{model_name}s WHERE #{model.class.to_s.downcase}Id = ?)", model.id)
    rows.map{|row|get_from_keys(row, keys)}
  end

  def self.count_through(db, klass, model)
    model_name = klass.to_s.downcase
    rows = db.execute("SELECT COUNT(*) FROM #{self.to_s.downcase}s WHERE #{model_name}Id IN (SELECT id FROM #{model_name}s WHERE #{model.class.to_s.downcase}Id = ?)", model.id)
    rows.first[0]
  end

  def self.create(db, items)
    name = self.to_s.downcase
    item_keys = items.keys.join(",")
    item_values = (["?"]*items.length).join(",")
    dbresult = db.execute("INSERT INTO #{name}s (#{item_keys}) VALUES (#{item_values})", items.values)
    id = db.execute('SELECT last_insert_rowid();').first[0]
    self.get(db, id)
  end

  def update(db, items)
    fields = []
    name = self.to_s.downcase
    item_keys = items.keys.join(",")
    item_values = (["?"]*items.length).join(",")
    fields = items.keys.map { |key| "#{key} = ?" }.join(",")
    db.execute("UPDATE #{itself.class.to_s.downcase}s SET #{fields} WHERE id = ?", items.values + [@id])
  end

  def self.foreign_keys(model)
    keys = []
    model::ATTRS.each do |attr|
      if attr.to_s.end_with?("Id")
        keys << attr.to_s.chomp("Id")
      end
    end
    keys
  end

  def self.has_many?(selfklass, classname)
    classname = classname.to_s.chomp('s').capitalize
    if Object.const_defined?(classname)
      klass = Object.const_get(classname)
      if klass < Model && klass::ATTRS.include?("#{selfklass.to_s.downcase}Id".to_sym)
        return true
      end
    end
    return false
  end

  def self.get_by(method, args)
    db = ConnectionPool.instance.obtain
    rows, keys = get_from_model(db, self, {"m.#{method.to_s.split("_")[-1]}" => args.first})
    ConnectionPool.instance.release(db)
    puts rows.inspect
    rows.map{|row|get_from_keys(row, keys)}
  end

  def self.get_many(method, args)
    klass = Object.const_get(method.to_s.chomp('s').capitalize)
    db = ConnectionPool.instance.obtain
    rows, keys = get_from_model(db, klass, {"#{self.to_s.downcase}Id" => args.first})
    ConnectionPool.instance.release(db)
    rows.map{|row|klass.get_from_keys(row, keys)}
  end

  def self.method_missing(method, *args)
    result = []
    if method.to_s.start_with?"get_by_"
      result = get_by(method, args)
    elsif has_many?(self, method)
      result = get_many(method, args)
    else
      raise ArgumentError, "Missing method #{method}"
    end
    result
  end

  def method_missing(method, *args)
    args << @id
    itself.class.method_missing(method, args)
  end

end
