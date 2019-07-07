module Cache
  class IssueCollectionRepository < Cache::CacheRepository
    def find(id)
      @records[id] ||= Factory.for(:issue_collection).create_from_json(JSON.parse(@client.get("issue_collection.#{id}")))
    end

    def save(issue_collection)
      @client.set("issue_collection.#{issue_collection.id}", ActiveModelSerializers::SerializableResource.new(issue_collection, include: ['issues', 'issues.epics']).to_json)
    end
  end
end
