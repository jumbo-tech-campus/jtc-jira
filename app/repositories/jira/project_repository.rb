module Jira
  class ProjectRepository < Jira::JiraRepository
    def find(key)
      @records[key] ||= Factory.for(:project).create_from_jira(@client.Project.find(key))
    end

    def all
      projects = Repository.for(:team).all.map{ |team| team.project }.uniq
      projects.each do |project|
        @records[project.key] = project
      end
      projects
    end
  end
end
