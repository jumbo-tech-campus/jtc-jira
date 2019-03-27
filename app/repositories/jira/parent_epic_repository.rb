module Jira
  class ParentEpicRepository < Jira::JiraRepository
    def find(key)
      @records[key] ||= Factory.for(:parent_epic).create_from_jira(@client.Issue.find(key))
    end
  end
end
