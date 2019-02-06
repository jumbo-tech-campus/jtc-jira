require_relative 'epic'
require_relative '../utils/date_helper'

class Issue
  attr_reader :key, :summary, :id, :source, :estimation, :created, :resolution_date, :sprint_change_events
  attr_accessor :epic

  def initialize(key, summary, id, estimation, created, resolution_date, source)
    @key, @summary, @id, @estimation, @created, @resolution_date, @source = key, summary, id, estimation, created, resolution_date, source
    @sprint_change_events = []
  end

  def self.from_jira(json)
    new(json['key'], json['fields']['summary'],
      json['id'], json['fields']['customfield_10014'] || 0,
      DateHelper.safe_parse(json['fields']['created']),
      DateHelper.safe_parse(json['fields']['resolutiondate']),
      json
    )
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
