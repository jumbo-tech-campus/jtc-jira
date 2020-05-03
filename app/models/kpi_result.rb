class KpiResult  < ActiveModelSerializers::Model
  attr_reader :result, :metrics
  attr_accessor :kpi_goal

  def initialize(result, metrics)
    @result, @metrics = result, metrics
  end

  def percentage_compared_to_goal
    (compared_to_goal / kpi_goal.current_target.to_f) * 100
  end

  def compared_to_goal
    result - kpi_goal.current_target
  end

  def is_positive?
    if kpi_goal.higher_is_better? && compared_to_goal > 0
      true
    elsif !kpi_goal.higher_is_better? && compared_to_goal < 0
      true
    else
      false
    end
  end
end
