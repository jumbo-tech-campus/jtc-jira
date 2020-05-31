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
      extract_issues(response, sprint.board.project.key)
    end

    def find_by_project_key(project_key)
      response = @client.Issue.jql("project=\"#{project_key}\"", expand: 'changelog')
      extract_issues(response, project_key)
    end

    def find_by_query(query)
      response = @client.Issue.jql(query, expand: 'changelog')
      extract_issues(response)
    end

    def filter_out_issue?(issue_json, project_key)
      #filter out subtasks, action requests, epics and parent epics
      if issue_json['fields']['issuetype']['subtask'] || ['Action Request', 'Epic', 'Parent Epic'].include?(issue_json['fields']['issuetype']['name'])
        return true
      #filter out issues from other projects
      elsif project_key && issue_json['fields']['project']['key'] != project_key
        return true
      else
        return false
      end
    end

    def extract_issues(response, project_key = nil)
      issues = []

      response.each do |issue_json|
        #filter out subtasks, action requests, epics and parent epics
        next if filter_out_issue?(issue_json, project_key)
        if @records[issue_json['key']]
          issues << @records[issue_json['key']]
          next
        end
        if issue_json['fields']['issuetype']['name'] == 'Incident'
          issue = Factory.for(:incident).create_from_jira(issue_json)
        elsif issue_json['fields']['issuetype']['name'] == 'Alert'
          issue = Factory.for(:alert).create_from_jira(issue_json)
        else
          issue = Factory.for(:issue).create_from_jira(issue_json)
        end

        @records[issue.key] = issue
        issues << issue
      end

      issues
    end
  end
end
