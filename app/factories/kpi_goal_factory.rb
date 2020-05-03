class KpiGoalFactory
  def create_from_json(json)
    quarter = Repository.for(:quarter).find(json['quarter_id'])
    department = Repository.for(:department).find(json['department_id'])

    kpi_goal = KpiGoal.new(json['id'], quarter, department)
    kpi_goal.metric = json['metric']
    kpi_goal.type = json['type'].to_sym
    kpi_goal.kpi_result = Factory.for(:kpi_result).create_from_json(json['kpi_result'])

    kpi_goal
  end

  def create_from_hash(hash)
    quarter = Repository.for(:quarter).find(hash[:quarter_id].to_i)
    department = Repository.for(:department).find(hash[:department_id].to_i)
    kpi_goal = KpiGoal.new(hash[:id], quarter, department)
    kpi_goal.metric = hash[:metric]
    kpi_goal.type = hash[:type].to_sym

    kpi_goal
  end
end
