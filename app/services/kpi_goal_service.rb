class KpiGoalService
  def initialize(department, quarter)
    @department, @quarter = department, quarter
  end

  def overview
    {
      table: table,
      report: KpiReport.new(goals),
      last_years_report: KpiReport.new(last_years_goals)
    }
  end

  def table
    table = []
    header = ['Type', "Goal #{@quarter.name}", 'Target for today', 'Result today', 'Compared to target', 'Positive result?']
    table << header
    goals.each do |goal|
      table << [
        KpiGoal::TYPES[goal.type],
        goal.metric.round(goal.decimal_precision),
        goal.current_target.round(goal.decimal_precision),
        goal.current_result.round(goal.decimal_precision),
        "#{goal.percentage_result_compared_to_target.round}%",
        goal.kpi_result.indication
      ]
    end

    table
  end

  def goals
    @goals ||= retrieve_goals(@quarter)
  end

  def last_years_goals
    @last_years_goals ||= retrieve_goals(last_years_quarter)
  end

  private

  def retrieve_goals(quarter)
    Repository.for(:kpi_goal).find_by(department: @department, quarter: quarter).sort_by(&:type)
  end

  def last_years_quarter
    Repository.for(:quarter).find_by(date: Date.commercial(@quarter.year - 1, @quarter.start_week, 5))
  end
end
