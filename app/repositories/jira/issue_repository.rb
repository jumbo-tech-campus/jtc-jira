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
        response = @client.Agile.get_sprint_issues(sprint.id, {startAt: start_at, expand: 'changelog'})

        response['issues'].each do |value|
          #filter out subtasks
          next if value['fields']['issuetype']['subtask']
          #filter on subteam
          if subteam
            next if value['fields']['customfield_12613'] && value['fields']['customfield_12613']['value'] != subteam
          end

          if @records[value['id']]
            issues << @records[value['id']]
            next
          end

          issue = Factory.for(:issue).create_from_jira(value)
          issue.epic = Repository.for(:epic).find(value['fields']['epic']['key']) if value['fields']['epic']

          state_changed_events = []
          value['changelog']['histories'].each do |history|
            history['items'].each do |item|
              if item['fieldId'] == 'status'
                state_changed_events << Factory.for(:state_changed_event).create_from_jira(history)
                break
              end
            end
          end

          issue.state_changed_events.concat(state_changed_events.sort_by{ |event| event.created })

          @records[issue.id] = issue
          issues << issue
        end

        start_at += response['maxResults']
        break if response['maxResults'] > response['issues'].length
      end

      issues
    end
  end
end
