class TeamFactory
  def create_from_json(json)
    team = Team.new(json['name'], json['board_id'], json['subteam'])
    team.project = Factory.for(:project).create_from_json(json['project'])
    team
  end
end
