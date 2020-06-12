class UptimeReportController < AuthenticatedController
  def overview
    @report = UptimeReportService.new(Date.commercial(2020, 20, 1).to_datetime, DateTime.new(2020, 12, 31)).uptime_report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@report[:issues_table]), filename: 'uptime_alert_issues.csv' }
      format.json { send_data @report.to_json }
    end
  end
end
