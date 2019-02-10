module Jira
  class EpicRepository < Jira::JiraRepository
    def find(key)
      @records[key] ||= Factory.for(:epic).create_from_jira(@client.Issue.find(key))
    end
  end
end
