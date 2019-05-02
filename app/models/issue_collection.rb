class IssueCollection < ActiveModelSerializers::Model
  attr_reader :issues, :id, :name, :jira_filter

  def initialize(id, name, jira_filter)
    @id, @name, @jira_filter = id, name, jira_filter
    @issues = []
  end

  def sorted_issues
    issues.sort_by(&:created)
  end
end
