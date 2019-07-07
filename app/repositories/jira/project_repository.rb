module Jira
  class ProjectRepository < Jira::JiraRepository
    def find(key)
      @records[key] ||= Factory.for(:project).create_from_jira(@client.Project.find(key))
    end

    def all
      Repository.for(:team).all.map{ |team| team.project }
    end
  end
end
