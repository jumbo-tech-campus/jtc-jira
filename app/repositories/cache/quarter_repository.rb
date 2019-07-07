module Cache
  class QuarterRepository < Cache::CacheRepository
    def all
      @all ||= JSON.parse(@client.get("quarters")).map do |quarter|
        Factory.for(:quarter).create_from_json(quarter)
      end
    end

    def find_by(options)
      if options[:fix_version]
        all.find{ |quarter| quarter.fix_version == options[:fix_version] }
      end
    end

    def save(quarters)
      @client.set("quarters", ActiveModelSerializers::SerializableResource.new(quarters).to_json)
    end
  end
end
