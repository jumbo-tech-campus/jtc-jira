class ReportController < ApplicationController
  before_action :set_week_dates, only: :portfolio

  def portfolio
    department_id = params[:department_id] || '1'
    @department = Repository.for(:department).find(department_id.to_i)

    @table = PortfolioReportService.for(@department.scrum_teams, @selected_date)

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@table), filename: "portfolio_report_week_#{@selected_date.cweek}_#{@selected_date.cweek + 1}.csv" }
    end
  end

  def deployment
    @report = DeploymentReportService.new.deployment_report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@report[:issues_table]), filename: "deployment_project_report.csv" }
      format.json { send_data @report.to_json }
    end
  end
end
