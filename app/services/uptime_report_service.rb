class UptimeReportService < BaseIssuesReportService
  def uptime_report
    {
      issues_table: issues_table
    }
  end

  def issues_table
    table = []
    header = ["Key", "Title", "Starts at", "Ends at", "Duration"]
    table << header
    downtime_events.each do |event|
      table << [
        event.alert_down.key,
        event.summary,
        event.started_at.strftime('%Y-%m-%d %H:%M'),
        event.ended_at&.strftime('%Y-%m-%d %H:%M'),
        ApplicationHelper.format_to_days_hours_and_minutes(event.duration)
      ]
    end

    table
  end

  def downtime_events
    issues_per_event_key = issues.reverse.inject({}) do |memo, issue|
      if memo[issue.event_key]
        memo[issue.event_key] << issue
      else
        memo[issue.event_key] = [issue]
      end
      memo
    end

    issues_per_event_key.map do |key, value|
      alerts = value.sort_by(&:alerted_at)
      DowntimeEvent.new(alerts.first, alerts.second)
    end
  end

  private
  def retrieve_issues
    ::Jira::IssueRepository.new(::Jira::JiraClient.new).find_by(query: "project = JDUA AND
      created >= #{@start_date.strftime('%Y-%m-%d')} AND
      created < #{(@end_date + 1.day).strftime('%Y-%m-%d')} ORDER BY created ASC, key DESC"
    )
  end
end
