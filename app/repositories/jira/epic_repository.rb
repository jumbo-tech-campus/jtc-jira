module Jira
  class EpicRepository < Jira::JiraRepository
    def find(key)
      return @records[key] if @records[key]

      jira_epic = @client.Issue.jql("key=#{key}").first
      if jira_epic
        @records[key] = Factory.for(:epic).create_from_jira(jira_epic)
      else
        puts "No epic found for #{key}"
      end

      @records[key]
    end

    def find_by(options)
      find_by_parent_epic(options[:parent_epic]) if options[:parent_epic]
    end

    private

    def find_by_parent_epic(parent_epic)
      epics = []
      response = @client.Issue.jql("\"Parent Link\"=#{parent_epic.key}")

      response.each do |value|
        if @records[value['key']]
          epics << @records[value['key']]
          next
        end

        epic = Factory.for(:epic).create_from_jira(value)

        @records[epic.key] = epic
        epics << epic
      end

      epics
    end
  end
end
