class EpicRepository
  def initialize(jira_client)
    @records = {}
    @client = jira_client
  end

  def find(key)
    @records[key] ||= Epic.from_jira(@client.Issue.find(key))
  end
end
