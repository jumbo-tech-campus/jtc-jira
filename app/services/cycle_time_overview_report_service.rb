class CycleTimeOverviewReportService
  def initialize(boards, start_date, end_date, period)
    @boards, @start_date, @end_date, @period = boards, start_date, end_date, period
  end

  def report
    periods = Period.create_periods(@start_date, @end_date, @period)

    table = []

    header = ["Team", "Constraint"]
    periods.each do |period|
      header << period.name
    end
    header << "Total avg"

    table << header

    @boards.each do |board|
      team = board.team
      row = [team.name, team.deployment_constraint.name]

      periods.each do |period|
        issues = cycle_issues([board], period.start_date, period.end_date)
        row << cycle_time_average(issues)&.round(1)
      end

      issues = cycle_issues([board], @start_date, @end_date)
      row << cycle_time_average(issues)&.round(1)

      table << row
    end

    row = ["Total", nil]

    periods.each do |period|
      issues = cycle_issues(@boards, period.start_date, period.end_date)
      row << cycle_time_average(issues)&.round(1)
    end
    table << row

    table
  end

  def cycle_issues(boards, start_date, end_date)
    boards.inject([]) do |memo, board|
      board_issues = board.issues_with_cycle_time.select do |issue|
        issue.done_date.between?(start_date, end_date.end_of_day)
      end
      memo.concat(board_issues)
      memo
    end
  end

  def cycle_time_average(issues)
    return nil if issues.size == 0

    issues.map(&:cycle_time).inject(:+) / issues.size.to_f
  end
end
