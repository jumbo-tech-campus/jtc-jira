class CacheService
  def self.refresh_team_data(team)
    redis_client = Cache::RedisClient.new
    JiraService.register_repositories
    CacheService.register_repositories

    board = Repository.for(:board).find(team.board_id)
    #use specific cache repositories to save to cache
    board_repo = ::Cache::BoardRepository.new(redis_client)
    sprint_repo = ::Cache::SprintRepository.new(redis_client)
    number_of_cached_sprints = YAML.load_file(Rails.root.join('config.yml'))[:number_of_cached_sprints]

    board_repo.save(board)
    board.recent_sprints(number_of_cached_sprints).each do |sprint|
      sprint_repo.save(sprint)
    end

    reset_repositories
  end

  def self.register_repositories
    redis_client = Cache::RedisClient.new
    Repository.register(:board, Cache::BoardRepository.new(redis_client))
    Repository.register(:sprint, Cache::SprintRepository.new(redis_client))
    Repository.register(:issue, Cache::IssueRepository.new(redis_client))
    Repository.register(:team, Cache::TeamRepository.new(redis_client))
    Repository.register(:department, Cache::DepartmentRepository.new(redis_client))
    Repository.register(:project, Cache::ProjectRepository.new(redis_client))
  end

  def reset_repositories
    config = YAML.load_file(Rails.root.join('config.yml'))
    if config[:use_cached_data]
      self.register_repositories
    else
      JiraService.register_repositories
      ConfigService.register_repositories
    end
  end
end
