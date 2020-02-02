class PortfolioReportController < ApplicationController
  before_action :set_week_dates, only: :overview
  before_action :set_quarters, only: [:epics_overview, :quarter_overview]

  caches_action :overview, expires_in: 12.hours, cache_path: :department_date_cache_path
  caches_action :epics_overview, expires_in: 12.hours, cache_path: :fix_version_cache_path
  caches_action :quarter_overview, expires_in: 12.hours, cache_path: :fix_version_cache_path

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
    @fix_version = params[:fix_version] || Repository.for(:quarter).find_by(date: Date.today).fix_version

    @report = ParentEpicService.new(@fix_version).epics_report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@report[:table]), filename: "portfolio_epics_#{@fix_version}.csv" }
    end
  end

  def quarter_overview
    @quarter = Repository.for(:quarter).find_by(fix_version: params[:fix_version]) || Repository.for(:quarter).find_by(date: Date.today)

    @report = PortfolioQuarterReportService.new(@quarter).quarter_report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@report[:table]), filename: "portfolio_quarter_#{@quarter.fix_version}.csv" }
    end
  end

  protected
  def department_date_cache_path
    { department_id: params[:department_id], date: params[:date] }
  end

  def fix_version_cache_path
    { fix_version: params[:fix_version] }
  end

  private
  def set_quarters
    @quarters = Repository.for(:quarter).all.sort_by(&:fix_version)
  end
end
