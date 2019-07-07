module Jira
  class EpicRepository < Jira::JiraRepository
    def find(key)
      @records[key] ||= Factory.for(:epic).create_from_jira(@client.Issue.jql("key=#{key}").first)
    end

    def find_by(options)
      if options[:parent_epic]
        find_by_parent_epic(options[:parent_epic])
      end
    end

    private
    def find_by_parent_epic(parent_epic)
      epics = []
      response = @client.Issue.jql("\"Parent Link\"=#{parent_epic.key}")

      response.each do |value|
        if @records[value['id']]
          epics << @records[value['id']]
          next
        end

        epic = Factory.for(:epic).create_from_jira(value)

        @records[epic.id] = epic
        epics << epic
      end

      epics
    end
  end
end
