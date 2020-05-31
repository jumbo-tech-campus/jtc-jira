module Cache
  class IssueRepository < Cache::CacheRepository
    def find_by(options)
      if options[:sprint]
        sprint = options[:sprint]
        return @records[sprint.uid] if @records[sprint.uid]

        sprint_json = @client.get("sprint.#{sprint.uid}")
        issues = if sprint_json
                   JSON.parse(sprint_json)['issues'].map do |issue_json|
                     if issue_json['class'] == 'Incident'
                       Factory.for(:incident).create_from_json(issue_json)
                     elsif issue_json['class'] == 'Alert'
                       Factory.for(:alert).create_from_json(issue_json)
                     else
                       Factory.for(:issue).create_from_json(issue_json)
                     end
                   end
                 else
                   []
                 end

        @records[sprint.uid] = issues
        issues
      end
    end
  end
end
