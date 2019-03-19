module Jira
  class DepartmentRepository < Jira::JiraRepository
    def all
      @all ||= YAML.load_file(Rails.root.join('departments.yml')).map do |config|
        Factory.for(:department).create_from_hash(config)
      end
    end

    def find(id)
      all.find{ |department| department.id == id }
    end
  end
end
