class IssueCountReportService
  def initialize(boards, start_date, end_date)
    @boards, @start_date, @end_date, @period = boards, start_date, end_date
  end

  def overview
    {
      issue_count_per_day: cumulative_count_per_day,
      count: issues.size
    }
  end

  def issues
    @issues ||= @boards.inject([]) do |memo, board|
      board_issues = board.issues_with_cycle_time.select do |issue|
        issue.release_date.between?(@start_date, @end_date.end_of_day) && board.team.is_active?(issue.release_date)
      end
      memo.concat(board_issues)
      memo
    end
  end

  def issue_count_per_day
    date = @start_date
    count_per_day = {}

    loop do
      break if date > @end_date

      count_per_day[date.strftime('%Y-%m-%d')] = 0
      date = date + 1.day
    end

    issues.inject(count_per_day) do |memo, issue|
      date = issue.release_date.strftime('%Y-%m-%d')
      memo[date] += 1
      memo
    end
  end

  def cumulative_count_per_day
    accumulator = 0
    issue_count_per_day.map do |day, count|
      accumulator += count
      [day, accumulator]
    end
  end
end
