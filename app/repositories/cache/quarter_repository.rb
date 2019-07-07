module Cache
  class QuarterRepository < Cache::CacheRepository
    def all
      @all ||= JSON.parse(@client.get("quarters")).map do |quarter|
        Factory.for(:quarter).create_from_json(quarter)
      end
    end

    def save(quarters)
      @client.set("quarters", ActiveModelSerializers::SerializableResource.new(quarters).to_json)
    end
  end
end
