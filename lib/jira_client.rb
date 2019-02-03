require 'jira-ruby'
require_relative 'models/board'
require_relative 'models/sprint'
require_relative 'models/sprint_epic'
require_relative 'models/parent_epic'
require_relative 'models/issue'
require_relative 'repositories/repository'

class JiraClient
  extend Forwardable

  def initialize
    options = {
      :username     => ENV['USERNAME'],
      :password     => ENV['API_KEY'],
      :site         => ENV['SITE'],
      :context_path => '',
      :auth_type    => :basic
    }

    @client = JIRA::Client.new(options)
  end

  def_delegators :@client, :Board

  def get_board_by_id(board_id)
    board = Repository.for(:board).find(board_id)
    board.sprints.concat(get_sprints_for(board))

    board
  end

  def get_sprints_for(board)
    start_at = 0
    sprints = []

    loop do
      response = @client.Agile.get_sprints(board.id, {startAt: start_at})

      response['values'].each do |sprint|
        sprint.transform_keys!(&:to_sym)
        sprints << Sprint.new(sprint)
      end

      start_at += response['maxResults']
      break if response['isLast']
    end
    sprints
  end

  def get_issues_for(sprint)
    start_at = 0
    issues = []

    loop do
      response = @client.Agile.get_sprint_issues(sprint.id, {startAt: start_at})
      response['issues'].each do |issue|
        #filter out subtasks
        next if issue['fields']['issuetype']['subtask']
        #filter out issues with certain field values
        if ENV['ISSUE_FILTER'] && ENV['ISSUE_FILTER_VALUE']
          next if issue['fields'][ENV['ISSUE_FILTER']]['value'] != ENV['ISSUE_FILTER_VALUE']
        end

        issues << Issue.from_json(issue)
      end

      start_at += response['maxResults']
      break if response['maxResults'] > response['issues'].length
    end

    issues
  end

  def get_parent_epic_for(sprint_epic)

    return nil unless sprint_epic.epic

    epic = @client.Issue.find(sprint_epic.epic.key)
    ParentEpic.from_json(epic.fields['customfield_11200'])
  end
end
