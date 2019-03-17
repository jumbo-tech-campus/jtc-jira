class Board < ActiveModelSerializers::Model
  attr_reader :id, :sprints
  attr_accessor :team

  def initialize(id)
    @id = id
    @sprints = []
  end

  def closed_sprints
    sprints.select{ |sprint| sprint.closed? }
  end

  def open_sprint
    sprints.select{ |sprint| !sprint.closed? }.first
  end

  def recent_closed_sprints(n)
    closed_sprints.sort_by{ |sprint| sprint.end_date }.reverse.take(n)
  end

  def recent_sprints(n)
    sprints.sort_by{ |sprint| sprint.end_date }.reverse.take(n)
  end

  def last_closed_sprint
    recent_closed_sprints(1).first
  end

  def sprint_for(date)
    sprints.find{ |sprint| date.between?(sprint.start_date, sprint.complete_date || sprint.end_date)}
  end

  def issues
    @issues ||= sprints.inject([]) do |memo, sprint|
      sprint.issues.each do |issue|
        memo << issue unless memo.include?(issue)
      end
      memo
    end
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
