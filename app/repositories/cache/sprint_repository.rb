module Cache
  class SprintRepository < Cache::CacheRepository
    def find_by(options)
      if options[:id] && options[:board]
        @records[uid(options)] ||= Factory.for(:sprint).create_from_json(JSON.parse(@client.get("sprint.#{uid(options)}")), options[:board])
      end
    end

    def save(sprint)
      # skip sprints that have no issues
      return if sprint.issues.empty?

      @client.set("sprint.#{sprint.uid}", ActiveModelSerializers::SerializableResource.new(sprint, include: ['issues', 'issues.epic', 'issues.epic.parent_epic']).to_json)
    end

    private

    def uid(options)
      "#{options[:board].id}_#{options[:id]}"
    end
  end
end
