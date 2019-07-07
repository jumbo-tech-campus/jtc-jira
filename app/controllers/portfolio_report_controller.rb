class PortfolioReportController < ApplicationController
  before_action :set_week_dates, only: :overview
  before_action :set_fix_versions, only: :epics_overview

  def overview
    department_id = params[:department_id] || '1'
    @department = Repository.for(:department).find(department_id.to_i)

    @table = PortfolioReportService.for(@department.scrum_teams, @selected_date)

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@table), filename: "portfolio_report_week_#{@selected_date.cweek}_#{@selected_date.cweek + 1}.csv" }
    end
  end

  def epics_overview
    @fix_version = params[:fix_version] || @fix_versions.first

    @report = ParentEpicService.new(@fix_version).epics_report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@report[:table]), filename: "portfolio_epics_#{@fix_version}.csv" }
    end
  end

  private
  def set_fix_versions
    @fix_versions = Repository.for(:issue_collection).find(3).issues.map(&:fix_version).compact.uniq.sort
  end
end
