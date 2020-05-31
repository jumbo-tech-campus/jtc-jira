class KpiGoal < ActiveModelSerializers::Model
  attr_reader :id, :quarter, :department
  attr_accessor :metric, :type, :kpi_result

  TYPES = {deployments: 'Deployments', issues: 'Released issues', cycle_time: 'Cycle time',
    p1s: 'P1 incidents', uptime: 'Uptime', time_to_recover: 'Time to recover',
    time_to_detect: 'Time to detect'
  }

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
        IssueCountReportService.new(department.teams, quarter.start_date, quarter.end_date).calculate_kpi_result
      when :p1s
        P1ReportService.new(quarter.start_date, quarter.end_date).calculate_kpi_result(:p1s)
      when :cycle_time
        CycleTimeReportService.new(department.teams, quarter.start_date, quarter.end_date).calculate_kpi_result
      when :uptime
        UptimeReportService.new(quarter.start_date, quarter.end_date).calculate_kpi_result
      when :time_to_recover
        P1ReportService.new(quarter.start_date, quarter.end_date).calculate_kpi_result(:time_to_recover)
      when :time_to_detect
        P1ReportService.new(quarter.start_date, quarter.end_date).calculate_kpi_result(:time_to_detect)
      else
        nil
      end
    @kpi_result.kpi_goal = self
    @kpi_result
  end

  def current_target
    if [:cycle_time, :uptime, :time_to_recover, :time_to_detect].include?(type)
      metric
    else
      (quarter.portion_passed * metric).round(decimal_precision)
    end
  end

  def percentage_result_compared_to_target
    kpi_result.percentage_compared_to_goal
  end

  def current_result
    kpi_result.result.round(decimal_precision)
  end

  def higher_is_better?
    case type
    when :deployments, :issues, :uptime
      true
    when :p1s, :time_to_recover, :cycle_time, :time_to_detect
      false
    else
      nil
    end
  end

  def decimal_precision
    if type == :cycle_time
      1
    elsif type == :uptime
      2
    else
      0
    end
  end
end
