class CycleTimeOverviewReportService
  def initialize(boards, start_date, end_date)
    @boards, @start_date, @end_date = boards, start_date, end_date
  end

  def report
    periods = Period.create_periods(@start_date, @end_date, 2.weeks)

    table = []

    header = ["Team", "Constraint"]
    periods.each do |period|
      header << period.name
    end
    table << header

    @boards.each do |board|
      team = board.team
      row = [team.name, team.deployment_constraint.name]

      periods.each do |period|
        issues = cycle_issues(board, period)
        row << cycle_time_average(issues)&.round(2)
      end

      table << row
    end

    table
  end

  def cycle_issues(board, period)
    board.issues_with_cycle_time.select do |issue|
      issue.done_date.between?(period.start_date, period.end_date.end_of_day)
    end
  end

  def cycle_time_average(issues)
    return nil if issues.size == 0

    issues.map(&:cycle_time).inject(:+) / issues.size.to_f
  end
end
