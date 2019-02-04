require_relative '../models/issue'
require_relative 'repository'

class IssueRepository
  def initialize
    @records = {}
    @client = JiraClient.new
  end

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
      response = @client.Agile.get_sprint_issues(sprint.id, {startAt: start_at})
      response['issues'].each do |value|
        #filter out subtasks
        next if value['fields']['issuetype']['subtask']
        #filter out issues with certain field values
        if ENV['ISSUE_FILTER'] && ENV['ISSUE_FILTER_VALUE']
          next if value['fields'][ENV['ISSUE_FILTER']]['value'] != ENV['ISSUE_FILTER_VALUE']
        end
        issue = Issue.from_jira(value)
        issue.epic = Repository.for(:epic).find(value['fields']['epic']['key']) if value['fields']['epic']

        @records[issue.id] = issue
        issues << issue
      end

      start_at += response['maxResults']
      break if response['maxResults'] > response['issues'].length
    end

    issues
  end
end
