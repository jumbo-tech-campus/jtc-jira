module Jira
  class IssueRepository < Jira::JiraRepository
    def find_by(options)
      if options[:sprint]
        find_by_sprint(options[:sprint])
      elsif options[:project_key]
        find_by_project_key(options[:project_key])
      elsif options[:query]
        find_by_query(options[:query])
      end
    end

    private
    def find_by_sprint(sprint)
      response = @client.Issue.jql("sprint=#{sprint.id}", expand: 'changelog')
      extract_issues(response, sprint.team)
    end

    def find_by_project_key(project_key)
      response = @client.Issue.jql("project=\"#{project_key}\"", expand: 'changelog')
      extract_issues(response)
    end

    def find_by_query(query)
      response = @client.Issue.jql(query, expand: 'changelog')
      extract_issues(response)
    end

    def filter_out_issue?(issue_json, team)
      #filter out subtasks, action requests, epics and parent epics
      return true if issue_json['fields']['issuetype']['subtask'] || ['Action Request', 'Epic', 'Parent Epic'].include?(issue_json['fields']['issuetype']['name'])
      if team
        #filter out issues from other projects
        return true unless issue_json['fields']['project']['key'] == team.project_key
        #filter on subteam
        if team.subteam
          return true if issue_json['fields']['customfield_12613'] && issue_json['fields']['customfield_12613']['value'] != team.subteam
        end
        #filter on component
        if team.component
          issue_json['fields']['components'].each do |component|
            return true if component['name'] != team.component
          end
        end
      end

      return false
    end

    def extract_issues(response, team = nil)
      issues = []

      response.each do |value|
        next if filter_out_issue?(value, team)
        if @records[value['key']]
          issues << @records[value['key']]
          next
        end
        if value['fields']['issuetype']['name'] == 'Incident'
          issue = Factory.for(:incident).create_from_jira(value)
        elsif value['fields']['issuetype']['name'] == 'Alert'
          issue = Factory.for(:alert).create_from_jira(value)
        else
          issue = Factory.for(:issue).create_from_jira(value)
        end

        @records[issue.key] = issue
        issues << issue
      end

      issues
    end
  end
end
