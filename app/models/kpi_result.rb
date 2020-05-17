class KpiResult  < ActiveModelSerializers::Model
  attr_reader :result, :metrics
  attr_accessor :kpi_goal

  def initialize(result, metrics)
    @result, @metrics = result, metrics
  end

  def percentage_compared_to_goal
    return 0 if kpi_goal.current_target == 0

    (compared_to_goal / kpi_goal.current_target.to_f) * 100
  end

  def compared_to_goal
    result - kpi_goal.current_target
  end

  def is_positive?
    if kpi_goal.higher_is_better? && compared_to_goal >= 0
      true
    elsif !kpi_goal.higher_is_better? && compared_to_goal <= 0
      true
    else
      false
    end
  end

  def indication
    if kpi_goal.higher_is_better? && percentage_compared_to_goal.round >= 0
      'positive'
    elsif kpi_goal.higher_is_better? && percentage_compared_to_goal.round.between?(-10, 0)
      'warning'
    elsif kpi_goal.higher_is_better? && percentage_compared_to_goal.round < -10
      'negative'
    elsif !kpi_goal.higher_is_better? && percentage_compared_to_goal.round <= 0
      'positive'
    elsif !kpi_goal.higher_is_better? && percentage_compared_to_goal.round.between?(0, 10)
      'warning'
    else
      'negative'
    end
  end
end
