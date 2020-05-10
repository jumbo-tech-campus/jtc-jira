class CycleTimeOverviewReportService
  def initialize(boards, start_date, end_date, period)
    @boards, @start_date, @end_date, @period = boards, start_date, end_date, period
  end

  def report(include_percentages = false)
    periods = Period.create_periods(@start_date, @end_date, @period)

    table = []

    header = ["Team", "Constraint"]
    periods.each do |period|
      header << period.name

      header << "Rel %" if include_percentages && period != periods.first
    end
    header << "Total avg"

    table << header

    @boards.each do |board|
      team = board.team
      row = [team.name, team.deployment_constraint.name]
      prev_period_avg = nil

      periods.each do |period|
        if team.is_active?(period.start_date)
          issues = cycle_issues([board], period.start_date, period.end_date)
          avg = cycle_time_average(issues)&.round(1)
          row << avg
        else
          row << nil
        end

        next unless include_percentages

        if prev_period_avg && avg
          row << "#{(((avg - prev_period_avg) /  prev_period_avg) * 100.0).round}%"
        elsif period != periods.first
          row << nil
        end
        prev_period_avg = avg
      end

      if team.started_at && team.started_at > @start_date
        started = team.started_at
      else
        started = @start_date
      end

      if team.archived_at && team.archived_at < @end_date
        ended = team.archived_at
      else
        ended = @end_date
      end

      issues = cycle_issues([board], started, ended)
      row << cycle_time_average(issues)&.round(1)

      table << row
    end

    row = ["Total", nil]

    prev_period_avg = nil
    periods.each do |period|
      boards = @boards.select{ |board| board.team.is_active?(period.start_date) }
      issues = cycle_issues(boards, period.start_date, period.end_date)
      avg = cycle_time_average(issues)&.round(1)
      row << avg

      next unless include_percentages

      if prev_period_avg && avg
        row << "#{(((avg - prev_period_avg) /  prev_period_avg) * 100.0).round}%"
      elsif period != periods.first
        row << nil
      end
      prev_period_avg = avg
    end
    table << row

    table
  end

  def cycle_issues(boards, start_date, end_date)
    boards.inject([]) do |memo, board|
      board_issues = board.issues_with_cycle_time.select do |issue|
        issue.release_date.between?(start_date, end_date.end_of_day) && board.team.is_active?(issue.release_date)
      end
      memo.concat(board_issues)
      memo
    end
  end

  def cycle_time_average(issues)
    return nil if issues.size == 0

    issues.map(&:cycle_time).inject(:+) / issues.size.to_f
  end

  def periodic_overall_results
    periods = Period.create_periods(@start_date, @end_date, @period)
    results = []

    periods.each do |period|
      boards = @boards.select{ |board| board.team.is_active?(period.start_date) }
      issues = cycle_issues(boards, period.start_date, period.end_date)
      avg = cycle_time_average(issues)&.round(1)
      results << [period.end_date.strftime('%W'), avg]
    end

    results
  end
end
