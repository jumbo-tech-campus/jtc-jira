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

      subteam = sprint.board.team.subteam
      loop do
        response = @client.Agile.get_sprint_issues(sprint.id, startAt: start_at)
        response['issues'].each do |value|
          #filter out subtasks
          next if value['fields']['issuetype']['subtask']
          #filter on subteam
          if subteam
            next if value['fields']['customfield_12613'] && value['fields']['customfield_12613']['value'] != subteam
          end

          issue = Factory.for(:issue).create_from_jira(value)
          issue.epic = Repository.for(:epic).find(value['fields']['epic']['key']) if value['fields']['epic']

          issues << issue
        end

        start_at += response['maxResults']
        break if response['maxResults'] > response['issues'].length
      end

      issues
    end
  end
end
