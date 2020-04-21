module Cache
  class KpiGoalRepository < Cache::CacheRepository
    def find(id)
      @records[id] ||= Factory.for(:kpi_goal).create_from_json(JSON.parse(@client.get("kpi_goal.#{id}")))
    end

    def save(kpi_goal)
      @client.set("kpi_goal.#{kpi_goal.id}", ActiveModelSerializers::SerializableResource.new(kpi_goal).to_json)
    end

    def delete(kpi_goal)
      @client.del("kpi_goal.#{kpi_goal.id}")
    end

    def all
      @client.keys("kpi_goal.*").map{ |id| find(id.sub('kpi_goal.', '')) }
    end

    def find_by(options)
      if options[:department]
        all.select{ |goal| goal.department == options[:department] }
      end
    end
  end
end
