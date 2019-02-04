class ParentEpic
  attr_reader :id, :key, :summary

  def initialize(id, key, summary)
    @id, @key, @summary = id, key, summary
  end

  def self.from_json(json)
    return nil if json.nil?

    new(json['id'], json['key'], json['summary'])
  end

  def ==(parent_epic)
    self.id == parent_epic.id
  end

  def to_s
    "Parent epic: #{key} #{summary}"
  end
end
