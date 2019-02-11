module Cache
  class SprintRepository
    def initialize(client)
      @client = client
      @records = {}
    end

    def find_by(options)
      if options[:id]
        @records[options[:id]] ||= Factory.for(:sprint).create_from_json(JSON.parse(@client.get("sprint.#{options[:subteam]}_#{options[:id]}")))
      end
    end

    def save(sprint)
      @client.set("sprint.#{sprint.subteam}_#{sprint.id}", ActiveModelSerializers::SerializableResource.new(sprint, include: ['issues', 'issues.epic', 'issues.epic.parent_epic']).to_json)
    end
  end
end
