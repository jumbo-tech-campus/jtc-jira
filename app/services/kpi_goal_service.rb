class KpiGoalService
  def initialize(department, quarter)
    @department, @quarter = department, quarter
  end

  def overview
    {
      table: table,
    }
  end

  def table
    table = []
    header = ["Type", "Goal #{@quarter.name}", "Target for today", "Result today", "Compared to target", "Positive result?"]
    table << header
    goals.each do |goal|
      table << [
        KpiGoal::TYPES[goal.type],
        goal.metric.round(goal.decimal_precision),
        goal.current_target,
        goal.current_result,
        "#{goal.percentage_result_compared_to_target.round}%",
        goal.kpi_result.is_positive?
      ]
    end

    table
  end

  def goals
    @goals ||= retrieve_goals
  end

  private
  def retrieve_goals
    Repository.for(:kpi_goal).find_by(department: @department, quarter: @quarter)
  end
end
