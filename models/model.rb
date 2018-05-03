class Model
  attr_reader :id

  def initialize(id)
    @id = id
  end

  # Denna metoden hämtar/sparar model av id som hör ihop med id.
  def self.get_or_initialize(id)
    if @modelsById.include? id
      @modelsById[id]
    else
      @modelsById[id] = @model.new(id)
    end
  end

  def self.hashToModel(dbmodel, items)
    items.keys.length.times do |i|
      writer = items.keys[i].to_s + "="
      if dbmodel.respond_to?(writer) && items.keys[i] != "id"
        dbmodel.send(writer, items.values[i])
      end
    end
    dbmodel
  end

  def self.get(db, id)
    dbmodel = get_or_initialize(id)
    db.results_as_hash = true
    dbresult = db.execute("SELECT * FROM #{self.to_s.downcase}s WHERE id = ?", id).first
    hashToModel(dbmodel, dbresult)
  end

  def self.get_from_keys(db, method, row, keys)
    dbmodel = get_or_initialize(row[0])
    if keys.length > 0
      keys.each do |key|
        field = db.execute("SELECT * FROM #{key}s WHERE id = ?", row[key.to_s + "Id"])
        klass = Object.const_get(key.to_s.capitalize)
        field.each do |row|
          writer = key.to_s + "="
          dbmodel.send(writer, klass.get(db, row[0]))
        end
      end
    end
    hashToModel(dbmodel, row)
  end

  def self.getAll(db)
    db.results_as_hash = true
    dbresult = db.execute("SELECT * FROM #{self.to_s.downcase}s")
    dbresult.map do |items|
      dbmodel = get_or_initialize(items["id"])
      hashToModel(dbmodel, items)
    end
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

  def foreign_keys(model)
    keys = []
    model::ATTRS.each do |attr|
      if attr.to_s.end_with?("Id")
        keys << attr.to_s.chomp("Id")
      end
    end
    keys
  end

  def self.method_missing(method, *args)
    result = []
    if method.to_s.start_with?"get_by_"
      db = ConnectionPool.instance.obtain
      db.results_as_hash = true
      dbresult = db.execute("SELECT * FROM #{self.to_s.downcase}s WHERE #{method.to_s.split("_")[-1]} = ?", args)
      dbresult.each do |items|
        dbmodel = get_or_initialize(items["id"])
        result << hashToModel(dbmodel, items)
      end
      ConnectionPool.instance.release(db)
    else
      raise ArgumentError, "Missing method #{method}"
    end
    result
  end

  def method_missing(method, *args)
    result = []
    if method.to_s.end_with?"s"
      keys = foreign_keys(Object.const_get(method.to_s.chomp('s').capitalize))
      db = ConnectionPool.instance.obtain
      db.results_as_hash = true
      field = db.execute("SELECT * FROM #{method} WHERE #{itself.class.to_s.downcase}Id = ?", @id)
      klass = Object.const_get(method.to_s.chomp('s').capitalize)
      field.each do |row|
        result << klass.get_from_keys(db, method, row, keys)
      end
      ConnectionPool.instance.release(db)
    else
      raise ArgumentError, "Missing method #{method}"
    end
    result
  end

end
