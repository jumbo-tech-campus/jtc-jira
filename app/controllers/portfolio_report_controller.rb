class PortfolioReportController < ApplicationController
  before_action :set_week_dates, only: [:teams_overview, :export]
  before_action :set_quarters, only: [:epics_overview, :quarter_overview]

  caches_action :export, expires_in: 12.hours, cache_path: :department_date_cache_path
  caches_action :teams_overview, expires_in: 12.hours, cache_path: :department_date_cache_path
  caches_action :epics_overview, expires_in: 12.hours, cache_path: :fix_version_cache_path
  caches_action :quarter_overview, expires_in: 12.hours, cache_path: :fix_version_cache_path

  def teams_overview
    department_id = params[:department_id] || '1'
    @department = Repository.for(:department).find(department_id.to_i)
    portfolio_service = PortfolioReportService.new(@department.active_scrum_teams(@selected_date), @selected_date)

    @table = portfolio_service.team_report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@table), filename: "portfolio_team_report_week_#{@selected_date.cweek}_#{@selected_date.cweek + 1}_#{@department.name}.csv" }
    end
  end

  def export
    teams = Repository.for(:department).all.inject([]) do |memo, department|
      memo.concat(department.active_teams(@selected_date).select(&:has_position?))
      memo
    end

    teams.sort_by!(&:position)

    portfolio_service = PortfolioReportService.new(teams, @selected_date)

    @table = portfolio_service.portfolio_export_report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@table), filename: "portfolio_export_week_#{@selected_date.cweek}_#{@selected_date.cweek + 1}.csv" }
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
