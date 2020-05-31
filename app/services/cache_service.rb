class CacheService
  def self.refresh_team_data(team)
    team = Config::TeamRepository.new(Config::ConfigClient.new).find(team.id)

    JiraService.register_repositories
    board = Repository.for(:board).find(team.board_id)

    redis_client = Cache::RedisClient.new

    # use specific cache repositories to save to cache
    team_repo = Cache::TeamRepository.new(redis_client)
    board_repo = Cache::BoardRepository.new(redis_client)
    sprint_repo = Cache::SprintRepository.new(redis_client)

    team_repo.save(team)
    board_repo.save(board)
    if team.is_scrum_team?
      team.sprints_from(2019).each do |sprint|
        sprint_repo.save(sprint)
      end
    end

    register_repositories
    Rails.cache.clear
  end

  def self.register_repositories
    redis_client = Cache::RedisClient.new
    Repository.register(:board, Cache::BoardRepository.new(redis_client))
    Repository.register(:sprint, Cache::SprintRepository.new(redis_client))
    Repository.register(:issue, Cache::IssueRepository.new(redis_client))
    Repository.register(:team, Cache::TeamRepository.new(redis_client))
    Repository.register(:department, Cache::DepartmentRepository.new(redis_client))
    Repository.register(:project, Cache::ProjectRepository.new(redis_client))
    Repository.register(:deployment_constraint, Cache::DeploymentConstraintRepository.new(redis_client))
    Repository.register(:quarter, Cache::QuarterRepository.new(redis_client))
    Repository.register(:parent_epic, Cache::ParentEpicRepository.new(redis_client))
    Repository.register(:kpi_goal, Cache::KpiGoalRepository.new(redis_client))
  end
end
