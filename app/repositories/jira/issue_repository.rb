module Jira
  class IssueRepository < Jira::JiraRepository
    def find_by(options)
      if options[:sprint]
        find_by_sprint(options[:sprint])
      end
    end

    private
    def find_by_sprint(sprint)
      start_at = 0
      issues = []

      loop do
        response = @client.Agile.get_sprint_issues(sprint.id, {startAt: start_at, expand: 'changelog'})
        response['issues'].each do |value|
          #filter out subtasks
          next if value['fields']['issuetype']['subtask']
          #filter on subteam
          if sprint.subteam
            next if value['fields']['customfield_12613'] && value['fields']['customfield_12613']['value'] != sprint.subteam
          end

          issue = Factory.for(:issue).create_from_jira(value)
          issue.epic = Repository.for(:epic).find(value['fields']['epic']['key']) if value['fields']['epic']


          value['changelog']['histories'].reverse.each do |history|
            next unless history['items'].first
            #this custom field changes when sprint is changed
            next if history['items'].first['fieldId'] != 'customfield_10020'
            issue.sprint_change_events << Factory.for(:sprint_change_event).create_from_jira(history, issue)
          end

          issues << issue
        end

        start_at += response['maxResults']
        break if response['maxResults'] > response['issues'].length
      end

      issues
    end
  end
end
