class DepartmentReportController < ApplicationController
  caches_action :cycle_time_overview, expires_in: 12.hours

  def cycle_time_overview
    department_id = params[:department_id] || '1'
    @department = Repository.for(:department).find(department_id.to_i)

    boards = @department.active_teams.map(&:board).compact.sort(&:name)
    @report = CycleTimeOverviewReportService.new(boards, DateTime.new(2019, 1, 1), DateTime.now, 1.year).report(true)
  end
end
