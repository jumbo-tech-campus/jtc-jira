require_relative '../utils/date_helper'
require_relative '../repositories/repository'

class SprintIssue
  attr_reader :id, :created, :to_sprint, :issue

  def initialize(id, created, to_sprint, issue)
    @id, @created, @to_sprint, @issue = id, created, to_sprint, issue
  end

  def self.from_jira(json, issue)
    to_sprint_id = json['items'].first['to'].split(',').last.to_i
    to_sprint  = Repository.for(:sprint).find(to_sprint_id) unless to_sprint_id == 0
    new(json['id'], DateHelper.safe_parse(json['created']),
      to_sprint,
      issue
    )
  end

  def added_after_sprint_start?
    return false unless to_sprint.start_date

    self.created > DateTime.new(to_sprint.start_date.year, to_sprint.start_date.month, to_sprint.start_date.day, 23, 59, 59, to_sprint.start_date.zone)
  end

  def to_s
    puts "created #{self.created}, sprint start date #{to_sprint.start_date}, issue #{issue.key}"
  end
end
