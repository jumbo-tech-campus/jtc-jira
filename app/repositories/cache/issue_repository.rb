module Cache
  class IssueRepository
    def initialize(client)
      @client = client
      @records = {}
    end

    def find_by(options)
      if options[:sprint]
        sprint = options[:sprint]
        return @records[sprint.id] if @records[sprint.id]
  
        sprint_json = JSON.parse(@client.get("sprint.#{sprint.subteam}_#{sprint.id}"))
        issues = sprint_json['issues'].map do |issue_json|
          Factory.for(:issue).create_from_json(issue_json)
        end

        @records[sprint.id] = issues
        issues
      end
    end
  end
end
