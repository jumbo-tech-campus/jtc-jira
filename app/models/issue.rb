class Issue < ActiveModelSerializers::Model
  attr_reader :key, :summary, :id, :estimation, :created, :resolution_date, :sprint_change_events
  attr_accessor :epic

  def initialize(key, summary, id, estimation, created, resolution_date)
    @key, @summary, @id, @estimation, @created, @resolution_date = key, summary, id, estimation, created, resolution_date
    @sprint_change_events = []
  end

  def added_after_sprint_start?(sprint)
    return true if self.created > sprint.start_date

    sprint_change_event = sprint_change_events.select{ |sprint_change_event| sprint_change_event.to_sprint == sprint }.first

    sprint_change_event&.added_after_sprint_start?
  end

  def jira_url
    URI.join(ENV['JIRA_SITE'], "browse/", key)
  end

  def to_s
    "Issue: #{key} #{summary}, estimation: #{estimation}, epic: #{epic&.name}"
  end
end
