class DeploymentReportController < ApplicationController
  before_action :set_last_week_dates

  def overview
    @report = DeploymentReportService.new(@start_date, @end_date).deployment_report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@report[:issues_table]), filename: "deployment_project_report.csv" }
      format.json { send_data @report.to_json }
    end
  end

  private
  def set_last_week_dates
    @end_date = ApplicationHelper.safe_parse(params[:end_date]) || DateTime.now.beginning_of_week - 1.week
    @start_date = ApplicationHelper.safe_parse(params[:start_date]) || DateTime.now.end_of_week - 1.week
  end
end
