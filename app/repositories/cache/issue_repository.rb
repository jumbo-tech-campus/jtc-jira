module Cache
  class IssueRepository
    def initialize(client)
      @client = client
      @records = {}
    end

    def find_by(options)
      if options[:sprint]
        sprint = options[:sprint]
        return @records[sprint.uid] if @records[sprint.uid]

        sprint_json = JSON.parse(@client.get("sprint.#{sprint.uid}"))
        issues = sprint_json['issues'].map do |issue_json|
          Factory.for(:issue).create_from_json(issue_json)
        end

        @records[sprint.uid] = issues
        issues
      end
    end
  end
end
