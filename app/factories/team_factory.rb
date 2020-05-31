class TeamFactory
  def create_from_json(json)
    team = Team.new(json['id'], json['name'], json['board_id'], json['subteam'])
    team.archived_at = ApplicationHelper.safe_parse(json['archived_at'])
    team.started_at = ApplicationHelper.safe_parse(json['started_at'])
    team.position = json['position']
    team.component = json['component']
    team.filter_sprints_by_team_name = json['filter_sprints_by_team_name']
    team.department = Factory.for(:department).create_from_json(json['department'])
    team.deployment_constraint = Factory.for(:deployment_constraint).create_from_json(json['deployment_constraint'])
    team
  end

  def create_from_hash(hash)
    team = Team.new(hash[:id], hash[:name], hash[:board_id], hash[:subteam])
    team.archived_at = ApplicationHelper.safe_parse(hash[:archived_at])
    team.started_at = ApplicationHelper.safe_parse(hash[:started_at])
    team.position = hash[:position]
    team.component = hash[:component]
    team.filter_sprints_by_team_name = hash[:filter_sprints_by_team_name]
    team.department = Repository.for(:department).find(hash[:department_id])
    team.deployment_constraint = Repository.for(:deployment_constraint).find(hash[:deployment_constraint_id])
    team
  end
end
