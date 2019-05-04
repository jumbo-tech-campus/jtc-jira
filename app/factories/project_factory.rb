class ProjectFactory
  def create_from_jira(jira_project)
    project = Project.new(jira_project.key, jira_project.name, jira_project.attrs['avatarUrls'])
  end

  def create_from_json(json)
    Project.new(json['key'], json['name'], json['avatars'])
  end
end
