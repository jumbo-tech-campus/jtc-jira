module Config
  class IssueCollectionRepository < Config::ConfigRepository
    def config_key
      :issue_collections
    end

    def object_type
      :issue_collection
    end

    def find_by(options)
      if options[:name]
        all.find{ |issue_collection| issue_collection.name == options[:name] }
      end
    end
  end
end
