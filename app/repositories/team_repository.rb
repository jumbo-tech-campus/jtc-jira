class TeamRepository
  def all
    teams_config = YAML.load_file(Rails.root.join('teams.yml'))
    teams_config.map do |config|
      team = Team.new(config[:name], config[:board_id], config[:subteam])
      team.project = Repository.for(:project).find(config[:project_key])
      team
    end
  end
end
