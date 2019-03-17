class Board < ActiveModelSerializers::Model
  attr_reader :id, :type
  attr_accessor :team

  def initialize(id, type)
    @id, @type = id, type
  end

  def cycle_times
    issues_with_cycle_time = issues.select{ |issue| issue.cycle_time }
    issues_with_cycle_time.sort_by!{ |issue| issue.done_date }

    @cycle_array ||= issues_with_cycle_time.map do |issue|
      [issue.key, issue.in_progress_date, issue.done_date, issue.cycle_time]
    end
  end

  def cycle_time_moving_average_on(date, period = 4.weeks)
    cycle_time_array = cycle_times.inject([]) do |memo, cycle_time|
      memo << cycle_time[3] if cycle_time[2].between?(date.end_of_day - period, date.end_of_day)
      memo
    end

    if cycle_time_array.size > 0
      cycle_time_array.inject(:+) / cycle_time_array.size.to_f
    else
      0
    end
  end
end
