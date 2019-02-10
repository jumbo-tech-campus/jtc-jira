class ParentEpic < ActiveModelSerializers::Model
  attr_reader :id, :key, :summary

  def initialize(id, key, summary)
    @id, @key, @summary = id, key, summary
  end

  def ==(parent_epic)
    self.id == parent_epic.id
  end

  def to_s
    "Parent epic: #{key} #{summary}"
  end
end
