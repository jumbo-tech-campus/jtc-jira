class IssueCollectionFactory
  def create_from_hash(hash)
    collection = IssueCollection.new(hash[:id], hash[:name], hash[:jira_filter])
    issues = Repository.for(:issue).find_by(filter: collection.jira_filter)
    collection.issues.concat(issues)
    collection
  end

  def create_from_json(json)
    collection = IssueCollection.new(json['id'], json['name'], json['jira_filter'])
    json['issues'].each do |issue|
      collection.issues << Factory.for(:issue).create_from_json(issue)
    end
    collection
  end
end
