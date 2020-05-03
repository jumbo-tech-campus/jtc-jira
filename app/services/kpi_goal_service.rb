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
    header = ["Type", "Goal #{@quarter.name}", "Target for today", "Result today", "Compared to target"]
    table << header
    goals.each do |goal|
      table << [
        KpiGoal::TYPES[goal.type],
        goal.metric,
        goal.current_target.round,
        goal.kpi_result.result,
        "#{goal.percentage_off_target.round}%"
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
