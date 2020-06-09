class KpiReport
  def initialize(goals)
    @goals = goals
  end

  def goal_for(type)
    @goals.find{ |goal| goal.type == type }
  end

  def contains_goal_for?(type)
    goal_for(type).present?
  end

  def metrics_for(type)
    goal_for(type)&.kpi_result&.metrics || []
  end

  def metric_for(type)
    goal_for(type)&.metric
  end
end
