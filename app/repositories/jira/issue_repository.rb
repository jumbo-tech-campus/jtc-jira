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

          if @records[value['key']]
            issues << @records[value['key']]
            next
          end

          issue = Factory.for(:issue).create_from_jira(value)

          @records[issue.key] = issue
          issues << issue
        end

        start_at += response['maxResults']
        break if response['maxResults'] > response['issues'].length
      end

      issues
    end

    def find_by_board(board)
      issues = []

      subteam = board.team.subteam
      response = @client.Board.find(board.id).issues(expand: 'changelog')

      response.each do |value|
        #filter out subtasks
        next if value['fields']['issuetype']['subtask']
        #filter on subteam
        if subteam
          next if value['fields']['customfield_12613'] && value['fields']['customfield_12613']['value'] != subteam
        end

        if @records[value['key']]
          issues << @records[value['key']]
          next
        end

        issue = Factory.for(:issue).create_from_jira(value)

        @records[issue.key] = issue
        issues << issue
      end

      issues
    end

    def find_by_project(project)
      issues = []

      response = @client.Project.find(project.key).issues(expand: 'changelog')

      response.each do |value|
        #filter out subtasks
        next if value['fields']['issuetype']['subtask']

        if @records[value['key']]
          issues << @records[value['key']]
          next
        end

        issue = Factory.for(:issue).create_from_jira(value)

        @records[issue.key] = issue
        issues << issue
      end

      issues
    end

    def find_by_filter(filter)
      issues = []
      response = @client.Issue.jql("filter=#{filter}", expand: 'changelog')

      response.each do |value|
        #filter out subtasks
        next if value['fields']['issuetype']['subtask']

        if @records[value['key']]
          issues << @records[value['key']]
          next
        end

        issue = Factory.for(:issue).create_from_jira(value)

        @records[issue.key] = issue
        issues << issue
      end

      issues
    end
  end
end
