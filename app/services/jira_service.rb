class JiraService
  def self.register_repositories
    jira_client = Jira::JiraClient.new

    issue_storage = {}
    Repository.register(:board, ::Jira::BoardRepository.new(jira_client))
    Repository.register(:sprint, ::Jira::SprintRepository.new(jira_client))
    Repository.register(:issue, ::Jira::IssueRepository.new(jira_client, issue_storage))
    Repository.register(:epic, ::Jira::EpicRepository.new(jira_client, issue_storage))
    Repository.register(:project, ::Jira::ProjectRepository.new(jira_client))
    Repository.register(:parent_epic, ::Jira::ParentEpicRepository.new(jira_client, issue_storage))
  end
end
