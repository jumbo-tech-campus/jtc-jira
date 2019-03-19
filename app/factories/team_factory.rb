class TeamFactory
  def create_from_json(json)
    team = Team.new(json['name'], json['board_id'], json['subteam'])
    team.project = Factory.for(:project).create_from_json(json['project'])
    team.department = Factory.for(:department).create_from_json(json['department'])
    team
  end

  def create_from_hash(hash)
    team = Team.new(hash[:name], hash[:board_id], hash[:subteam])
    team.project = Repository.for(:project).find(hash[:project_key])
    team.department = Repository.for(:department).find(hash[:department_id])
    team
  end
end
