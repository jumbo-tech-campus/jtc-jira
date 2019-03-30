module Cache
  class TeamRepository < Cache::CacheRepository
    def all
      @all ||= JSON.parse(@client.get("teams")).map do |team|
        Factory.for(:team).create_from_json(team)
      end
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

    def save(teams)
      @client.set("teams", ActiveModelSerializers::SerializableResource.
        new(teams, include: ['project', 'department', 'deployment_constraint']).to_json)
    end
  end
end
