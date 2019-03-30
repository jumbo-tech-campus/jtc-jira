class TeamFactory
  def create_from_json(json)
    team = Team.new(json['name'], json['board_id'], json['subteam'])
    team.project = Factory.for(:project).create_from_json(json['project'])
    team.department = Factory.for(:department).create_from_json(json['department'])
    team.deployment_constraint = Factory.for(:deployment_constraint).create_from_json(json['deployment_constraint'])
    team
  end

  def create_from_hash(hash)
    team = Team.new(hash[:name], hash[:board_id], hash[:subteam])
    team.project = Repository.for(:project).find(hash[:project_key])
    team.department = Repository.for(:department).find(hash[:department_id])
    team.deployment_constraint = Repository.for(:deployment_constraint).find(hash[:deployment_constraint_id])
    team
  end
end
