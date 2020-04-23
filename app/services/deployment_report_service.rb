class DeploymentReportService < BaseIssuesReportService
  def deployment_report
    {
      issues_table: issues_table,
      issue_count_per_day: issue_count_per_day.to_a,
      trend_count_per_week: linear_regression_for_issue_count
    }
  end

  private
  def retrieve_issues
    ::Jira::IssueRepository.new(::Jira::JiraClient.new).find_by(query: "project = JDD AND
      created > #{@start_date.strftime('%Y-%m-%d')} AND
      created <= #{@end_date.strftime('%Y-%m-%d')} ORDER BY created ASC, key DESC"
    )
  end
end
