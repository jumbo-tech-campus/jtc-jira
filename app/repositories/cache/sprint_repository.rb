module Cache
  class SprintRepository
    def initialize(client)
      @client = client
      @records = {}
    end

    def find(id)
      @records[id] ||= Sprint.from_cache(JSON.parse(@client.get("sprint.#{id}")))
    end

    def save(sprint)
      @client.set("sprint.#{sprint.id}", ActiveModelSerializers::SerializableResource.new(sprint, include: ['issues', 'issues.epic', 'issues.epic.parent_epic']).to_json)
    end
  end
end