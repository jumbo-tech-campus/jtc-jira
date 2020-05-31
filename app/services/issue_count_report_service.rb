class IssueCountReportService < BaseIssuesReportService
  def initialize(teams, start_date, end_date)
    super(start_date, end_date)
    @teams = teams
  end

  def issue_count_property
    :release_date
  end

  def retrieve_issues
    @teams.each_with_object([]) do |team, memo|
      team_issues = team.issues_with_cycle_time.select do |issue|
        issue.release_date.between?(@start_date, @end_date.end_of_day) && team.is_active?(issue.release_date)
      end
      memo.concat(team_issues)
    end
  end
end
