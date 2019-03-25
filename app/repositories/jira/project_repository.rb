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
      projects = Repository.for(:team).all.map{ |team| team.project }
      configured_deployment_projects.each do |config| 
        projects << find(config[:key])
      end
      projects
    end

    private
    def configured_deployment_projects
      YAML.load_file(Rails.root.join('seed.yml'))[:deployment_projects]
    end
  end
end
