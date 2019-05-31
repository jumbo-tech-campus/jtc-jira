module Jira
  class ParentEpicRepository < Jira::JiraRepository
    def find(key)
      @records[key] ||= Factory.for(:parent_epic).create_from_jira(JSON.parse(@client.Issue.find(key).to_json))
    end
  end
end
