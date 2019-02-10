module Jira
  class EpicRepository < Jira::JiraRepository
    def find(key)
      @records[key] ||= Epic.from_jira(@client.Issue.find(key))
    end
  end
end
