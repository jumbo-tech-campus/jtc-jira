class KanbanBoard < Board
  attr_reader :issues

  def initialize(*args)
    super
    @issues = []
  end

  def sprints_for(date)
    [sprint_for(date)]
  end

  def sprint_for(date)
    start_date = date.beginning_of_week
    # sprints always start on uneven weeks
    start_date -= 1.week if start_date.cweek.even?

    end_date = start_date.end_of_week + 1.week

    sprint = KanbanSprint.new(0, "Week #{start_date.cweek} & #{end_date.cweek} #{end_date.year}", '', start_date, end_date, end_date)
    sprint.board = self
    sprint
  end

  def last_closed_sprint
    week_begin = Date.today.beginning_of_week
    start_date = if week_begin.cweek.even?
                   week_begin - 3.weeks
                 else
                   week_begin - 2.weeks
                 end

    sprint_for(start_date)
  end

  def sprints_from(year)
    date = DateTime.new(year, 1, 1)
    dates = [date]

    loop do
      date += 2.weeks
      break if date > DateTime.now

      dates << date
    end

    dates.map do |sprint_date|
      sprint_for(sprint_date)
    end
  end

  def sprints
    @sprints ||= sprints_from(2019)
  end
end
