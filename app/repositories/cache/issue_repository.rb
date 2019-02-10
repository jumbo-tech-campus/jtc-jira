module Cache
  class IssueRepository
    def initialize(client)
      @client = client
      @records = {}
    end

    def find_by(options)
      if options[:sprint]
        return @records[options[:sprint].id] if @records[options[:sprint].id]
        sprint_json = JSON.parse(@client.get("sprint.#{options[:sprint].id}"))
        issues = sprint_json['issues'].map do |issue_json|
          Factory.for(:issue).create_from_json(issue_json)
        end

        @records[options[:sprint].id] = issues
        issues
      end
    end
  end
end
