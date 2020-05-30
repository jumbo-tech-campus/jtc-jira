class DepartmentReportController < ApplicationController
  before_action :set_current_quarters
  before_action :set_department
  caches_action :cycle_time_overview, expires_in: 12.hours, cache_path: :department_cache_path

  def cycle_time_overview
    @report = CycleTimeOverviewReportService.new(@department.teams, DateTime.new(2019, 1, 1), DateTime.now, 1.year).report(true)
  end

  def kpi_dashboard
    @report = KpiGoalService.new(@department, @current_quarter).overview

    respond_to do |format|
      format.html { render :kpi_dashboard }
      format.csv { send_data to_csv(@report[:table]), filename: "kpi_dashboard_#{@department.name}_#{@current_quarter.name}.csv" }
      format.json { send_data @report.to_json }
    end
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
