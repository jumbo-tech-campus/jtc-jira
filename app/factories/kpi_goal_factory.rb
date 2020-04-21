class KpiGoalFactory
  def create_from_json(json)
    quarter = Repository.for(:quarter).find(json['quarter_id'])
    department = Repository.for(:department).find(json['department_id'])

    kpi_goal = KpiGoal.new(json['id'], quarter, department)
    kpi_goal.metric = json['metric']
    kpi_goal.type = json['type']

    kpi_goal
  end

  def create_from_hash(hash)
    quarter = Repository.for(:quarter).find(hash[:quarter_id].to_i)
    department = Repository.for(:department).find(hash[:department_id].to_i)
    kpi_goal = KpiGoal.new(hash[:id], quarter, department)
    kpi_goal.metric = hash[:metric]
    kpi_goal.type = hash[:type]

    kpi_goal
  end
end
