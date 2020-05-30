module Cache
  class TeamRepository < Cache::CacheRepository
    def find(id)
      @records[id] ||= Factory.for(:team).create_from_json(JSON.parse(@client.get("team.#{id}")))
    end

    def all
      @client.keys("team.*").map{ |id| find(id.sub('team.', '')) }
    end

    def find_by(options)
      if options[:board_id]
        all.select{ |team| team.board_id == options[:board_id]}
      elsif options[:department_id]
        all.select{ |team| team.department.id == options[:department_id]}
      elsif options[:deployment_constraint_id]
        all.select{ |team| team.deployment_constraint.id == options[:deployment_constraint_id]}
      end
    end

    def save(team)
      @client.set("team.#{team.id}", ActiveModelSerializers::SerializableResource.
        new(team, include: ['project', 'department', 'deployment_constraint']).to_json)
    end
  end
end
