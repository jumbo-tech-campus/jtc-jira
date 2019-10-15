class Board < ActiveModelSerializers::Model
  attr_reader :id, :type
  attr_accessor :team

  def initialize(id, type)
    @id, @type = id, type
  end

  def issues_with_cycle_time
    @issues_with_cycle_time ||= issues.select(&:cycle_time).sort_by(&:release_date)
  end

  def issues_with_short_cycle_time
    @issues_with_short_cycle_time ||= issues.select(&:short_cycle_time).sort_by(&:pending_release_date)
  end

  def issues_with_cycle_time_delta
    @issues_with_cycle_time_delta ||= issues.select(&:cycle_time_delta).sort_by(&:release_date)
  end
end
