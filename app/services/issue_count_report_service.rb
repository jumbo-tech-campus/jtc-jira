class IssueCountReportService < BaseIssuesReportService
  def initialize(boards, start_date, end_date)
    super(start_date, end_date)
    @boards = boards
  end

  def issue_count_property
    :release_date
  end

  def retrieve_issues
    @boards.inject([]) do |memo, board|
      board_issues = board.issues_with_cycle_time.select do |issue|
        issue.release_date.between?(@start_date, @end_date.end_of_day) && board.team.is_active?(issue.release_date)
      end
      memo.concat(board_issues)
      memo
    end
  end
end
