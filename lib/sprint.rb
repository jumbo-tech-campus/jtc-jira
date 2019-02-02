require 'dry-struct'
require_relative 'types'

class Sprint < Dry::Struct
  attribute :name, Types::Strict::String
  attribute :state, Types::Strict::String
  attribute :endDate, Types::Params::DateTime.meta(omittable: true)
  attribute :startDate, Types::Params::DateTime.meta(omittable: true)

  def closed?
    state == 'closed'
  end

  def to_s
    "Name: #{name}"
  end
end
