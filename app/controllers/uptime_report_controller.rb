class UptimeReportController < ApplicationController
  before_action :set_year_dates

  def overview
    @report = UptimeReportService.new(@start_date, @end_date).uptime_report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@report[:issues_table]), filename: "uptime_alert_issues.csv" }
      format.json { send_data @report.to_json }
    end
  end
end
