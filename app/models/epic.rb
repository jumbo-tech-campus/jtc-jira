class Epic < ActiveModelSerializers::Model
  attr_reader :key, :summary, :id, :name
  attr_accessor :parent_epic

  def initialize(key, summary, id, name)
    @key, @summary, @id, @name = key, summary, id, name
  end

  def description
    "#{key} - #{summary}"
  end

  def ==(epic)
    self.id == epic.id
  end

  def to_s
    "Epic: #{key} #{name}"
  end
end
