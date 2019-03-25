class ProjectFactory
  def create_from_jira(jira_project)
    if configured_deployment_projects.any?{ |project| project[:key] == jira_project.key }
      project = DeploymentProject.new(jira_project.key, jira_project.name, jira_project.attrs['avatarUrls'])

      issues = Repository.for(:issue).find_by(project: project)
      project.issues.concat(issues)
    else
      project = Project.new(jira_project.key, jira_project.name, jira_project.attrs['avatarUrls'])
    end
    project
  end

  def create_from_json(json)
    if configured_deployment_projects.any?{ |project| project[:key] == json['key'] }
      project = DeploymentProject.new(json['key'], json['name'], json['avatars'])
      json['issues'].each do |issue|
        project.issues << Factory.for(:issue).create_from_json(issue)
      end
    else
      project = Project.new(json['key'], json['name'], json['avatars'])
    end
    project
  end

  private
  def configured_deployment_projects
    YAML.load_file(Rails.root.join('seed.yml'))[:deployment_projects]
  end
end
