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

  def self.get(id)
    dbmodel = get_or_initialize(id)
    $db.results_as_hash = true
    dbresult = $db.execute("SELECT * FROM #{self.to_s.downcase}s WHERE id = ?", id).first
    hashToModel(dbmodel, dbresult)
  end

  def self.getAll
    $db.results_as_hash = true
    dbresult = $db.execute("SELECT * FROM #{self.to_s.downcase}s")
    dbresult.map do |items|
      dbmodel = get_or_initialize(items["id"])
      hashToModel(dbmodel, items)
    end
  end

  def self.create(items)
    name = self.to_s.downcase
    item_keys = items.keys.join(",")
    item_values = (["?"]*items.length).join(",")
    dbresult = $db.execute("INSERT INTO #{name}s (#{item_keys}) VALUES (#{item_values})", items.values)
    id = db.execute('SELECT last_insert_rowid();').first.first
    self.get(id)
  end

  def update(items)
    fields = []
    name = self.to_s.downcase
    item_keys = items.keys.join(",")
    item_values = (["?"]*items.length).join(",")
    fields = items.keys.map { |key| "#{key} = ?" }.join(",")
    $db.execute("UPDATE #{itself.class.to_s.downcase}s SET #{fields} WHERE id = ?", items.values + [@id])
  end

  def self.method_missing(method, *args)
    result = []
    if method.to_s.start_with?"get_by_"
      $db.results_as_hash = true
      dbresult = $db.execute("SELECT * FROM #{self.to_s.downcase}s WHERE #{method.to_s.split("_")[-1]} = ?", args)
      dbresult.each do |items|
        dbmodel = get_or_initialize(items["id"])
        result << hashToModel(dbmodel, items)
      end
    else
      raise ArgumentError, "Missing method #{method}"
    end
    result
  end

  def method_missing(method, *args)
    result = []
    if method.to_s.end_with?"s"
      seats = $db.execute("SELECT * FROM #{method} WHERE #{itself.class.to_s.downcase}Id = ?", @id)
      seats.each do |seat|
        result << Seat.get(seat[0])
      end
    else
      raise ArgumentError, "Missing method #{method}"
    end
    result
  end

end
