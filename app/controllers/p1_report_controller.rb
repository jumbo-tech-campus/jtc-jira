class P1ReportController < ApplicationController
  before_action :set_dates

  def overview
    @report = P1ReportService.new(@start_date, @end_date).p1_report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@report[:closed_issues_table]), filename: "closed_p1_issues.csv" }
      format.json { send_data @report.to_json }
    end
  end

  private
  def set_dates
    @end_date = ApplicationHelper.safe_parse(params[:end_date]) || DateTime.new(Date.today.year,12,31)
    @start_date = ApplicationHelper.safe_parse(params[:start_date]) || DateTime.new(Date.today.year,1,1)
  end
end
