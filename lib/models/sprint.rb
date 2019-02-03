require_relative 'issue'
require_relative 'sprint_epic'
require_relative '../utils/date_helper'
require_relative '../repositories/repository'

class Sprint
  attr_reader :id, :name, :state, :startDate, :endDate, :completeDate, :issues, :parent_epics

  def initialize(id, name, state, startDate, endDate, completeDate)
    @id, @name, @state, @startDate, @endDate, @completeDate = id, name, state, startDate, endDate, completeDate
    @issues = nil
    @parent_epics = []
  end

  def self.from_json(json)
    new(json['id'], json['name'], json['state'],
      DateHelper.safe_parse(json['startDate']),
      DateHelper.safe_parse(json['endDate']),
      DateHelper.safe_parse(json['completeDate']),
    )
  end

  def closed?
    state == 'closed'
  end

  def issues
    @issues ||= Repository.for(:issue).find_by(sprint: self)
  end

  def closed_issues
    issues.select{ |issue| issue.resolution_date && issue.resolution_date <= completeDate }
  end

  def points_closed
    closed_issues.reduce(0){ |sum, issue| sum + issue.estimation }
  end

  def sprint_epics
    no_sprint_epic = SprintEpic.new(self, nil)

    sp = closed_issues.inject([]) do |memo, issue|
      if issue.epic
        sprint_epic = SprintEpic.new(self, issue.epic)
        if memo.include?(sprint_epic)
          memo[memo.index(sprint_epic)].total_points += issue.estimation
        else
          sprint_epic.total_points = issue.estimation
          memo << sprint_epic
        end
      else
        no_sprint_epic.total_points += issue.estimation
      end
      memo
    end

    sp << no_sprint_epic
  end

  def to_s
    "Name: #{name}"
  end
end
