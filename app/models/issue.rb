class Issue < ActiveModelSerializers::Model
  attr_reader :key, :summary, :id, :estimation, :created, :resolution_date, :sprint_change_events
  attr_accessor :epic

  def initialize(key, summary, id, estimation, created, resolution_date)
    @key, @summary, @id, @estimation, @created, @resolution_date = key, summary, id, estimation, created, resolution_date
    @sprint_change_events = []
  end

  def self.from_jira(json)
    new(json['key'], json['fields']['summary'],
      json['id'], json['fields']['customfield_10014'] || 0,
      ApplicationHelper.safe_parse(json['fields']['created']),
      ApplicationHelper.safe_parse(json['fields']['resolutiondate'])
    )
  end

  def self.from_cache(json)
    issue = new(json['key'], json['summary'],
      json['id'], json['estimation'],
      ApplicationHelper.safe_parse(json['created']),
      ApplicationHelper.safe_parse(json['resolution_date'])
    )
    issue.epic = Epic.from_cache(json['epic'])
    issue
  end

  def added_after_sprint_start?(sprint)
    return true if self.created > sprint.start_date

    sprint_change_event = sprint_change_events.select{ |sprint_change_event| sprint_change_event.to_sprint == sprint }.first

    sprint_change_event&.added_after_sprint_start?
  end

  def to_s
    "Issue: #{key} #{summary}, estimation: #{estimation}, epic: #{epic&.name}"
  end
end
