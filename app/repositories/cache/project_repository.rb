module Cache
  class ProjectRepository < Cache::CacheRepository
    def all
      @all ||= JSON.parse(@client.get('projects')).map do |project|
        Factory.for(:project).create_from_json(project)
      end
    end

    def find(key)
      all.find { |project| project.key == key }
    end

    def save(projects)
      @client.set('projects', ActiveModelSerializers::SerializableResource.new(projects).to_json)
    end
  end
end
