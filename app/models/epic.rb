class Epic < ActiveModelSerializers::Model
  attr_reader :key, :summary, :id, :name, :status
  attr_accessor :parent_epic

  def initialize(key, summary, id, name, status)
    @key, @summary, @id, @name, @status = key, summary, id, name, status
  end

  def description
    "#{key} - #{summary}"
  end

  def ==(epic)
    self.id == epic.id
  end
end
