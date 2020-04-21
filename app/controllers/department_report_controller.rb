class DepartmentReportController < ApplicationController
  before_action :set_current_quarters
  caches_action :cycle_time_overview, expires_in: 12.hours, cache_path: :department_cache_path

  def cycle_time_overview
    department_id = params[:department_id] || '1'
    @department = Repository.for(:department).find(department_id.to_i)

    boards = @department.teams.map(&:board).compact
    @report = CycleTimeOverviewReportService.new(boards, DateTime.new(2019, 1, 1), DateTime.now, 1.year).report(true)
  end

  def deployments_overview
    current_deploy = DeploymentReportService.new(@current_quarter.start_date, @current_quarter.end_date).overview
    last_year_deploy = DeploymentReportService.new(@last_year_quarter.start_date, @last_year_quarter.end_date).overview

    @report = {
      current: current_deploy[:issue_count_per_day],
      previous: last_year_deploy[:issue_count_per_day]
    }
  end

  def issues_overview
    department_id = params[:department_id] || '1'
    @department = Repository.for(:department).find(department_id.to_i)

    boards = @department.teams.map(&:board).compact
    current_issues = IssueCountReportService.new(boards, @current_quarter.start_date, @current_quarter.end_date).overview
    last_year_issues = IssueCountReportService.new(boards, @last_year_quarter.start_date, @last_year_quarter.end_date).overview

    @report = {
      current: current_issues[:issue_count_per_day],
      previous: last_year_issues[:issue_count_per_day]
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
end
