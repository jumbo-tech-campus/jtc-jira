module Jira
  class ParentEpicRepository < Jira::JiraRepository
    def find(key)
      @records[key] ||= Factory.for(:parent_epic).create_from_jira(@client.Issue.jql("key=#{key}").first)
    end

    def all
      query = "project = PK AND type = \"Parent Epic\" ORDER BY created DESC, key ASC"
      parent_epics = Repository.for(:issue).find_by(query: query)

      parent_epics.each do |parent_epic|
        epics = Repository.for(:epic).find_by(parent_epic: parent_epic)
        parent_epic.epics.concat(epics)
        @records[parent_epic.key] = parent_epic
      end

      parent_epics
    end
  end
end
