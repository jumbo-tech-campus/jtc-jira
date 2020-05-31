module Cache
  class QuarterRepository < Cache::CacheRepository
    def all
      @all ||= JSON.parse(@client.get('quarters')).map do |quarter|
        Factory.for(:quarter).create_from_json(quarter)
      end
    end

    def find(id)
      all.find { |quarter| quarter.id == id }
    end

    def find_by(options)
      if options[:fix_version]
        all.find { |quarter| quarter.fix_version == options[:fix_version] }
      elsif options[:date]
        all.find { |quarter| options[:date].cweek >= quarter.start_week && options[:date].cweek <= quarter.end_week && quarter.year == options[:date].year }
      end
    end

    def save(quarters)
      @client.set('quarters', ActiveModelSerializers::SerializableResource.new(quarters).to_json)
    end
  end
end
