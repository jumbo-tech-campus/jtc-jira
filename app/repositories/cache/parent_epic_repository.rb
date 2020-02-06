module Cache
  class ParentEpicRepository < Cache::CacheRepository
    def all
      @all ||= JSON.parse(@client.get("parent_epics")).map do |parent_epic|
        Factory.for(:parent_epic).create_from_json(parent_epic)
      end
    end

    def find(key)
      all.find{ |parent_epic| parent_epic.key == key }
    end

    def find_by(options)
      if options[:fix_version]
        all.select{ |parent_epic| parent_epic.fix_versions.include?(options[:fix_version]) }
      end
    end

    def save(parent_epics)
      @client.set("parent_epics", ActiveModelSerializers::SerializableResource.
        new(parent_epics, include: ['epics']).to_json)
    end
  end
end
