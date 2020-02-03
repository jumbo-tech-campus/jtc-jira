class DepartmentReportController < ApplicationController
  caches_action :cycle_time_overview, expires_in: 12.hours, cache_path: :department_cache_path

  def cycle_time_overview
    department_id = params[:department_id] || '1'
    @department = Repository.for(:department).find(department_id.to_i)

    boards = @department.active_teams.sort_by(&:name).map(&:board).compact
    @report = CycleTimeOverviewReportService.new(boards, DateTime.new(2019, 1, 1), DateTime.now, 1.year).report(true)
  end

  protected
  def department_cache_path
    { department_id: params[:department_id] }
  end
end
