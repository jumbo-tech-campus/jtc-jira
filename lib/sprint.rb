require 'dry-struct'
require_relative 'types'
require_relative 'issue'

class Sprint < Dry::Struct
  attribute :name, Types::Strict::String
  attribute :id, Types::Coercible::Integer
  attribute :state, Types::Strict::String
  attribute :endDate, Types::Params::DateTime.meta(omittable: true)
  attribute :startDate, Types::Params::DateTime.meta(omittable: true)
  attribute :completeDate, Types::Params::DateTime.meta(omittable: true)
  attribute :issues, Types::Strict::Array.default([])

  def closed?
    state == 'closed'
  end

  def closed_issues
    issues.select{ |issue| issue.resolution_date && issue.resolution_date <= completeDate }
  end

  def points_closed
    closed_issues.reduce(0){ |sum, issue| sum + issue.estimation }
  end

  def to_s
    "Name: #{name}"
  end
end
