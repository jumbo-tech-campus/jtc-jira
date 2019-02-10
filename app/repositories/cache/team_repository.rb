module Cache
  class TeamRepository
    def initialize(client)
      @client = client
    end

    def all
      JSON.parse(@client.get("teams")).map do |team|
        Team.from_cache(team)
      end
    end

    def save(teams)
      @client.set("teams", ActiveModelSerializers::SerializableResource.new(teams, include: ['project']).to_json)
    end
  end
end
