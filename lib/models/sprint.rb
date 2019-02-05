require_relative 'issue'
require_relative 'sprint_epic'
require_relative 'sprint_parent_epic'
require_relative 'sprint_issue_abilities'
require_relative '../utils/date_helper'
require_relative '../repositories/repository'

class Sprint
  attr_reader :id, :name, :state, :percentage_of_points_closed, :end_date, :complete_date

  include SprintIssueAbilities

  def initialize(id, name, state, start_date, end_date, complete_date)
    @id, @name, @state, @start_date, @end_date, @complete_date = id, name, state, start_date, end_date, complete_date

    sprint_issue_abilities(self, nil)
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

  def sprint_epics
    return @sprint_epics if @sprint_epics

    no_sprint_epic = SprintEpic.new(self, Epic.new('X', '', 0, 'Issues without epic'))

    @sprint_epics = issues.inject([]) do |memo, issue|
      if issue.epic
        sprint_epic = SprintEpic.new(self, issue.epic)
        if memo.include?(sprint_epic)
          sprint_epic = memo[memo.index(sprint_epic)]
        else
          memo << sprint_epic
        end
      else
        sprint_epic = no_sprint_epic
      end
      sprint_epic.issues << issue

      memo
    end

    @sprint_epics << no_sprint_epic if no_sprint_epic.issues.size > 0
  end

  def sprint_parent_epics
    return @sprint_parent_epics if @sprint_parent_epics

    no_sprint_parent_epic = SprintParentEpic.new(self, ParentEpic.new(0, 'X', 'Issues without parent epic'))

    @sprint_parent_epics = sprint_epics.inject([]) do |memo, sprint_epic|
      if sprint_epic.parent_epic
        sprint_parent_epic = SprintParentEpic.new(self, sprint_epic.parent_epic)
        if memo.include?(sprint_parent_epic)
          sprint_parent_epic = memo[memo.index(sprint_parent_epic)]
        else
          memo << sprint_parent_epic
        end
      else
        sprint_parent_epic = no_sprint_parent_epic
      end
      sprint_parent_epic.issues.concat(sprint_epic.issues)
      memo
    end

    @sprint_parent_epics << no_sprint_parent_epic if no_sprint_parent_epic.issues.size > 0
  end

  def to_s
    "Sprint: #{name}, points closed: #{points_closed}"
  end
end
