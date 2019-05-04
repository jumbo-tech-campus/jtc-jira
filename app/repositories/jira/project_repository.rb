module Jira
  class ProjectRepository
    def initialize(jira_client)
      @records = {}
      @client = jira_client
    end

    def find(key)
      @records[key] ||= Factory.for(:project).create_from_jira(@client.Project.find(key))
    end

    def all
      Repository.for(:team).all.map{ |team| team.project }
    end
  end
end
