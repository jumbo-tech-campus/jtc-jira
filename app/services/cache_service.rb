class CacheService
  def initialize
    @redis_client = Cache::RedisClient.new
  end

  def refresh_team_data(team)
    JiraService.new.register_jira_repositories

    board = Repository.for(:board).find(team.board_id)
    #use specific cache repositories to save to cache
    board_repo = ::Cache::BoardRepository.new(@redis_client)
    sprint_repo = ::Cache::SprintRepository.new(@redis_client)

    board_repo.save(board)
    board.recent_sprints(6).each do |sprint|
      sprint_repo.save(sprint)
    end

    reset_repositories
  end

  def register_cache_repositories
    Repository.register(:board, Cache::BoardRepository.new(@redis_client))
    Repository.register(:sprint, Cache::SprintRepository.new(@redis_client))
    Repository.register(:issue, Cache::IssueRepository.new(@redis_client))
    Repository.register(:team, Cache::TeamRepository.new(@redis_client))
  end

  def reset_repositories
    config = YAML.load_file(Rails.root.join('config.yml'))
    if config[:use_cached_data]
      self.register_cache_repositories
    else
      JiraService.new.register_jira_repositories
    end
  end
end
