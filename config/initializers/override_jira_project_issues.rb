JIRA::Resource::Project.class_eval do
  def issues(params = {})
    JIRA::Resource::Issue.jql(client, "project=\"#{key}\"", params)
  end
end
