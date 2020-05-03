class DepartmentReportController < ApplicationController
  before_action :set_current_quarters
  before_action :set_department
  caches_action :cycle_time_overview, expires_in: 12.hours, cache_path: :department_cache_path

  def cycle_time_overview
    boards = @department.teams.map(&:board).compact
    @report = CycleTimeOverviewReportService.new(boards, DateTime.new(2019, 1, 1), DateTime.now, 1.year).report(true)
  end

  def deployments_overview
    current_deploy = DeploymentReportService.new(@current_quarter.start_date, @current_quarter.end_date).overview
    last_year_deploy = DeploymentReportService.new(@last_year_quarter.start_date, @last_year_quarter.end_date).overview

    @kpi_goal = Repository.for(:kpi_goal).find_by(department: @department, quarter: @current_quarter, type: :deployments).first

    @report = {
      current: current_deploy[:issue_count_per_day],
      previous: last_year_deploy[:issue_count_per_day]
    }
  end

  def kpi_overview
    @report = KpiGoalService.new(@department, @current_quarter).overview
  end

  def issues_overview
    boards = @department.teams.map(&:board).compact
    current_issues = IssueCountReportService.new(boards, @current_quarter.start_date, @current_quarter.end_date).overview
    last_year_issues = IssueCountReportService.new(boards, @last_year_quarter.start_date, @last_year_quarter.end_date).overview

    @kpi_goal = Repository.for(:kpi_goal).find_by(department: @department, quarter: @current_quarter, type: :issues).first

    @report = {
      current: current_issues[:issue_count_per_day],
      previous: last_year_issues[:issue_count_per_day]
    }
  end

  def p1s_overview
    current_p1s = P1ReportService.new(@current_quarter.start_date, @current_quarter.end_date).overview
    last_year_p1s = P1ReportService.new(@last_year_quarter.start_date, @last_year_quarter.end_date).overview

    @kpi_goal = Repository.for(:kpi_goal).find_by(department: @department, quarter: @current_quarter, type: :p1s).first

    @report = {
      current: current_p1s[:issue_count_per_day],
      previous: last_year_p1s[:issue_count_per_day]
    }
  end

  protected
  def department_cache_path
    { department_id: params[:department_id] }
  end

  def set_current_quarters
    @quarters = Repository.for(:quarter).all.select{ |quarter| quarter.year >= 2020 }
    if params[:quarter_id].present?
      @current_quarter = Repository.for(:quarter).find(params[:quarter_id].to_i)
    else
      @current_quarter = Repository.for(:quarter).find_by(date: Date.today)
    end
    @last_year_quarter = Repository.for(:quarter).find_by(date: Date.commercial(@current_quarter.year - 1, @current_quarter.start_week, 5))
  end

  def set_department
    department_id = params[:department_id] || '1'
    @department = Repository.for(:department).find(department_id.to_i)
  end
end
