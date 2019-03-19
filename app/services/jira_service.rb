class JiraService
  def initialize
    @jira_client = Jira::JiraClient.new
  end

  def register_jira_repositories
    Repository.register(:board, ::Jira::BoardRepository.new(@jira_client))
    Repository.register(:sprint, ::Jira::SprintRepository.new(@jira_client))
    Repository.register(:issue, ::Jira::IssueRepository.new(@jira_client))
    Repository.register(:epic, ::Jira::EpicRepository.new(@jira_client))
    Repository.register(:project, ::Jira::ProjectRepository.new(@jira_client))
    Repository.register(:team, ::Jira::TeamRepository.new(@jira_client))
    Repository.register(:department, ::Jira::DepartmentRepository.new(@jira_client))
  end
end
