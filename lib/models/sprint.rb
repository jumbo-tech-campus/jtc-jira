require 'dry-struct'
require_relative 'types'
require_relative 'issue'
require_relative 'sprint_epic'

class Sprint < Dry::Struct
  attribute :name, Types::Strict::String
  attribute :id, Types::Coercible::Integer
  attribute :state, Types::Strict::String
  attribute :endDate, Types::Params::DateTime.meta(omittable: true)
  attribute :startDate, Types::Params::DateTime.meta(omittable: true)
  attribute :completeDate, Types::Params::DateTime.meta(omittable: true)
  attribute :issues, Types::Strict::Array.default([])
  attribute :parent_epics, Types::Strict::Array.default([])

  def closed?
    state == 'closed'
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
