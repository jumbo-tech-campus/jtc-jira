class DepartmentReportController < ApplicationController
  caches_action :cycle_time_overview, expires_in: 12.hours, cache_path: :department_cache_path

  def cycle_time_overview
    department_id = params[:department_id] || '1'
    @department = Repository.for(:department).find(department_id.to_i)

    boards = @department.active_teams.map(&:board).compact
    @report = CycleTimeOverviewReportService.new(boards, DateTime.new(2019, 1, 1), DateTime.now, 1.year).report(true)
  end

  def deployments_overview
    @current_quarter = Repository.for(:quarter).find_by(date: Date.today)
    @last_year_quarter = Repository.for(:quarter).find_by(date: Date.today - 1.year)

    current_deploy = DeploymentReportService.new(@current_quarter.start_date, @current_quarter.end_date).overview
    last_year_deploy = DeploymentReportService.new(@last_year_quarter.start_date, @last_year_quarter.end_date).overview

    @report = {
      current: current_deploy[:issue_count_per_day],
      previous: last_year_deploy[:issue_count_per_day]
    }
  end

  protected
  def department_cache_path
    { department_id: params[:department_id] }
  end
end
