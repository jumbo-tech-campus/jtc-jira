module Jira
  class IssueRepository < Jira::JiraRepository
    def find_by(options)
      if options[:sprint]
        find_by_sprint(options[:sprint])
      elsif options[:board]
        find_by_board(options[:board])
      elsif options[:project]
        find_by_project(options[:project])
      elsif options[:filter]
        find_by_filter(options[:filter])
      elsif options[:query]
        find_by_query(options[:query])
      end
    end

    private
    def find_by_sprint(sprint)
      response = @client.Issue.jql("sprint=#{sprint.id}", expand: 'changelog')
      extract_issues(response, sprint.board)
    end


    def find_by_board(board)
      response = @client.Board.find(board.id).issues(expand: 'changelog')
      extract_issues(response, board)
    end

    def find_by_project(project)
      response = @client.Project.find(project.key).issues(expand: 'changelog')
      extract_issues(response)
    end

    def find_by_filter(filter)
      response = @client.Issue.jql("filter=#{filter}", expand: 'changelog')
      extract_issues(response)
    end

    def find_by_query(query)
      response = @client.Issue.jql(query, expand: 'changelog')
      extract_issues(response)
    end

    def filter_out_issue?(issue_json, board)
      #filter out subtasks and action requests
      return true if issue_json['fields']['issuetype']['subtask'] || issue_json['fields']['issuetype']['name'] == 'Action Request'

      if board
        #filter out issues from other projects
        return true unless issue_json['fields']['project']['key'] == board.team.project_key
        #filter on subteam
        if board.team.subteam
          return true if issue_json['fields']['customfield_12613'] && issue_json['fields']['customfield_12613']['value'] != board.team.subteam
        end
      end

      return false
    end

    def extract_issues(response, board = nil)
      issues = []

      response.each do |value|
        next if filter_out_issue?(value, board)
        if @records[value['key']]
          issues << @records[value['key']]
          next
        end

        issue = Factory.for(:issue).create_from_jira(value)
        next unless issue.is_a? Issue

        @records[issue.key] = issue
        issues << issue
      end

      issues
    end
  end
end
