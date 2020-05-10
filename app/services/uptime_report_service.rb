class UptimeReportService < BaseIssuesReportService
  def uptime_report
    {
      issues_table: issues_table
    }
  end

  private
  def retrieve_issues
    ::Jira::IssueRepository.new(::Jira::JiraClient.new).find_by(query: "project = JDUA AND
      created >= #{@start_date.strftime('%Y-%m-%d')} AND
      created < #{(@end_date + 1.day).strftime('%Y-%m-%d')} ORDER BY created ASC, key DESC"
    )
  end
end
