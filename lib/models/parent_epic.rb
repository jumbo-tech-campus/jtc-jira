class ParentEpic
  attr_reader :id, :key, :summary

  def initialize(id, key, summary)
    @id, @key, @summary = id, key, summary
  end

  def self.from_json(json)
    data = json['data']
    new(data['id'], data['key'], data['summary'])
  end

  def to_s
    "Parent epic: #{key} #{summary}"
  end
end
