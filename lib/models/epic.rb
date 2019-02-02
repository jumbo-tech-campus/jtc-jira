class Epic
  attr_reader :key, :summary, :id, :name

  def initialize(key, summary, id, name)
    @key, @summary, @id, @name = key, summary, id, name
  end

  def self.from_json(json)
    new(json['key'], json['summary'],
      json['id'], json['name']
    )
  end

  def ==(epic)
    id == epic.id
  end
end
