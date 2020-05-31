module Jira
  class ParentEpicRepository < Jira::JiraRepository
    def find(key)
      @records[key] ||= Factory.for(:parent_epic).create_from_jira(@client.Issue.jql("key=#{key}").first)
    end

    def all
      query = 'project = PK AND type = "Parent Epic" ORDER BY created DESC, key ASC'
      response = @client.Issue.jql(query)

      parent_epics = []

      response.each do |value|
        if @records[value['key']]
          parent_epics << @records[value['key']]
          next
        end

        parent_epic = Factory.for(:parent_epic).create_from_jira(value)
        epics = Repository.for(:epic).find_by(parent_epic: parent_epic)
        parent_epic.epics.concat(epics)

        @records[parent_epic.key] = parent_epic
        parent_epics << parent_epic
      end

      parent_epics
    end
  end
end
