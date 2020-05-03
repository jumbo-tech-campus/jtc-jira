class KpiGoal < ActiveModelSerializers::Model
  TYPES = {deployments: 'Deployments', issues: 'Released issues', cycle_time: 'Cycle time', p1s: 'P1 incidents'}

  attr_reader :id, :quarter, :department
  attr_accessor :metric, :type, :kpi_result

  def initialize(id, quarter, department)
    @id, @quarter, @department = id, quarter, department
  end

  def quarter_id
    @quarter&.id
  end

  def department_id
    @department&.id
  end

  def calculate_kpi_result
    @kpi_result = case type
      when :deployments
        DeploymentReportService.new(quarter.start_date, quarter.end_date).calculate_kpi_result
      when :issues
        IssueCountReportService.new(department.boards, quarter.start_date, quarter.end_date).calculate_kpi_result
      when :p1s
        P1ReportService.new(quarter.start_date, quarter.end_date).calculate_kpi_result
      when :cycle_time
        CycleTimeReportService.new(department.boards, quarter.start_date, quarter.end_date).calculate_kpi_result
      else
        nil
      end
  end

  def current_target
    quarter.portion_passed * metric.to_i
  end

  def percentage_off_target
    ((kpi_result.result - current_target) / current_target.to_f) * 100
  end
end
