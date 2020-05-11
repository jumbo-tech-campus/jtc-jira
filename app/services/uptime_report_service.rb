class UptimeReportService < BaseIssuesReportService
  def uptime_report
    {
      issues_table: issues_table
    }
  end

  def issues_table
    table = []
    header = ["Key", "Title", "Alerted at", "Event key"]
    table << header
    issues.reverse.each do |issue|
      table << [
        issue.key,
        issue.summary,
        issue.alerted_at.strftime('%Y-%m-%d %H:%M'),
        issue.event_key
      ]
    end

    table
  end

  private
  def retrieve_issues
    ::Jira::IssueRepository.new(::Jira::JiraClient.new).find_by(query: "project = JDUA AND
      created >= #{@start_date.strftime('%Y-%m-%d')} AND
      created < #{(@end_date + 1.day).strftime('%Y-%m-%d')} ORDER BY created ASC, key DESC"
    )
  end
end
