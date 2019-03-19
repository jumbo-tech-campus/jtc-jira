module Cache
  class TeamRepository < Cache::CacheRepository
    def all
      JSON.parse(@client.get("teams")).map do |team|
        Factory.for(:team).create_from_json(team)
      end
    end

    def save(teams)
      @client.set("teams", ActiveModelSerializers::SerializableResource.new(teams, include: ['project']).to_json)
    end
  end
end
