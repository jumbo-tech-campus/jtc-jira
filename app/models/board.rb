class Board < ActiveModelSerializers::Model
  attr_reader :id, :type
  attr_accessor :team

  def initialize(id, type)
    @id, @type = id, type
  end

  def issues_with_cycle_time
    @issues_with_cycle_time ||= issues.select{ |issue| issue.cycle_time }.sort_by{ |issue| issue.done_date }
  end

  def issues_with_short_cycle_time
    @issues_with_short_cycle_time ||= issues.select{ |issue| issue.short_cycle_time }.sort_by{ |issue| issue.ready_for_prod_date }
  end

  def cycle_time_moving_average_on(date, period = 4.weeks)
    cycle_time_array = issues_with_cycle_time.inject([]) do |memo, issue|
      memo << issue.cycle_time if issue.done_date.between?(date.end_of_day - period, date.end_of_day)
      memo
    end

    if cycle_time_array.size > 0
      cycle_time_array.inject(:+) / cycle_time_array.size.to_f
    else
      0
    end
  end

  def short_cycle_time_moving_average_on(date, period = 4.weeks)
    cycle_time_array = issues_with_short_cycle_time.inject([]) do |memo, issue|
      memo << issue.short_cycle_time if issue.ready_for_prod_date.between?(date.end_of_day - period, date.end_of_day)
      memo
    end

    if cycle_time_array.size > 0
      cycle_time_array.inject(:+) / cycle_time_array.size.to_f
    else
      0
    end
  end
end
