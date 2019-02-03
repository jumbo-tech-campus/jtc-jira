require_relative 'epic'

class Issue
  attr_reader :key, :summary, :id, :source, :estimation, :resolution_date
  attr_accessor :epic

  def initialize(key, summary, id, estimation, resolution_date, source)
    @key, @summary, @id, @estimation, @resolution_date, @source = key, summary, id, estimation, resolution_date, source
  end

  def self.from_json(json)
    new(json['key'], json['fields']['summary'],
      json['id'], json['fields']['customfield_10014'] || 0,
      json['fields']['resolutiondate'],
      json
    )
  end

  def to_s
    "Issue: #{key} #{summary}, estimation: #{estimation}, epic: #{epic&.name}"
  end
end
