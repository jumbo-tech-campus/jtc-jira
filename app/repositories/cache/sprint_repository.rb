module Cache
  class SprintRepository < Cache::CacheRepository
    def find_by(options)
      if options[:id]
        if options[:team].is_scrum_team?
          @records[uid(options)] ||= Factory.for(:sprint).create_from_json(JSON.parse(@client.get("sprint.#{uid(options)}")), options[:team])
        else
          year_week = options[:id].split('_')
          @records[uid(options)] ||= options[:board].sprint_for(Date.commercial(year_week[0].to_i, year_week[1].to_i, 1))
        end
      end
    end

    def save(sprint)
      # skip sprints that have no issues
      return if sprint.issues.size == 0

      @client.set("sprint.#{sprint.uid}", ActiveModelSerializers::SerializableResource.new(sprint, include: ['issues', 'issues.epic', 'issues.epic.parent_epic']).to_json)
    end

    private
    def uid(options)
      "#{options[:board].id}_#{options[:id]}"
    end
  end
end
