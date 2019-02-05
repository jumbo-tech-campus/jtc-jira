require_relative '../utils/date_helper'
require_relative '../repositories/repository'

class SprintIssue
  attr_reader :id, :created, :sprint, :issue

  def initialize(id, created, sprint, issue)
    @id, @created, @sprint, @issue = id, created, sprint, issue
  end

  def self.from_jira(json, issue)
    sprint_id = json['items'].first['to'].split(',').last.to_i
    sprint  = Repository.for(:sprint).find(sprint_id) unless sprint_id == 0
    new(json['id'], DateHelper.safe_parse(json['created']),
      sprint,
      issue
    )
  end

  def added_after_sprint_start?
    return false unless sprint.start_date

    self.created > sprint.start_date
  end

  def to_s
    puts "created #{self.created}, sprint start date #{sprint.start_date}, issue #{issue.key}"
  end
end
