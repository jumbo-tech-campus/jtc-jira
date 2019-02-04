require_relative 'issue'
require_relative 'sprint_epic'
require_relative 'sprint_parent_epic'
require_relative '../utils/date_helper'
require_relative '../repositories/repository'

class Sprint
  attr_reader :id, :name, :state, :startDate, :endDate, :completeDate, :issues

  def initialize(id, name, state, startDate, endDate, completeDate)
    @id, @name, @state, @startDate, @endDate, @completeDate = id, name, state, startDate, endDate, completeDate
    @issues = nil
    @sprint_epics = nil
    @sprint_parent_epics = nil
  end

  def self.from_jira(json)
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
    return @sprint_epics if @sprint_epics

    no_sprint_epic = SprintEpic.new(self, Epic.new('X', 'Undefined', 0, 'Undefined'))

    @sprint_epics = closed_issues.inject([]) do |memo, issue|
      if issue.epic
        sprint_epic = SprintEpic.new(self, issue.epic)
        if memo.include?(sprint_epic)
          memo[memo.index(sprint_epic)].points_closed += issue.estimation
        else
          sprint_epic.points_closed = issue.estimation
          memo << sprint_epic
        end
      else
        no_sprint_epic.points_closed += issue.estimation
      end
      memo
    end

    @sprint_epics << no_sprint_epic
  end

  def sprint_parent_epics
    return @sprint_parent_epics if @sprint_parent_epics

    no_sprint_parent_epic = SprintParentEpic.new(self, ParentEpic.new(0, 'X', 'Undefined'))

    @sprint_parent_epics = sprint_epics.inject([]) do |memo, sprint_epic|
      if sprint_epic.parent_epic
        sprint_parent_epic = SprintParentEpic.new(self, sprint_epic.parent_epic)
        if memo.include?(sprint_parent_epic)
          memo[memo.index(sprint_parent_epic)].points_closed += sprint_epic.points_closed
        else
          sprint_parent_epic.points_closed = sprint_epic.points_closed
          memo << sprint_parent_epic
        end
      else
        no_sprint_parent_epic.points_closed += sprint_epic.points_closed
      end

      memo
    end

    @sprint_parent_epics << no_sprint_parent_epic
  end

  def to_s
    "Sprint: #{name}, points closed: #{points_closed}"
  end
end
