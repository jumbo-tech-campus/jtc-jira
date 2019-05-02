module Config
  class IssueCollectionRepository < Config::ConfigRepository
    def all
      @records ||= @client.get(:issue_collections).map do |config_hash|
        Factory.for(:issue_collection).create_from_hash(config_hash)
      end
    end

    def find(id)
      all.find{ |issue_collection| issue_collection.id == id }
    end

    def find_by(options)
      if options[:name]
        all.find{ |issue_collection| issue_collection.name == options[:name] }
      end
    end
  end
end
