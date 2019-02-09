class TeamRepository
  def all
    teams_config = YAML.load_file(Rails.root.join('teams.yml'))
    teams_config.map do |config|
      team = Team.new(config[:name], config[:board_id], config[:subteam])
      team.project = Repository.for(:project).find(config[:project_key])
      team
    end
  end

  def find_by(options)
    if options[:board_id]
      all.select{ |team| team.board_id == options[:board_id]}
    end
  end
end
