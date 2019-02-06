require_relative '../models/issue'
require_relative '../models/sprint_change_event'
require_relative 'repository'

class IssueRepository
  def initialize(jira_client, config)
    @client = jira_client
    @config = config
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
      response = @client.Agile.get_sprint_issues(sprint.id, {startAt: start_at, expand: 'changelog'})
      response['issues'].each do |value|
        #filter out subtasks
        next if value['fields']['issuetype']['subtask']
        #filter on subteam
        if @config.filter_subteam?
          next if value['fields']['customfield_12613']['value'] != @config.subteam_name
        end

        issue = Issue.from_jira(value)
        issue.epic = Repository.for(:epic).find(value['fields']['epic']['key']) if value['fields']['epic']


        value['changelog']['histories'].reverse.each do |history|
          #this custom field changes when sprint is changed
          next if history['items'].first['fieldId'] != 'customfield_10020'
          issue.sprint_change_events << SprintChangeEvent.from_jira(history, issue)
        end

        issues << issue
      end

      start_at += response['maxResults']
      break if response['maxResults'] > response['issues'].length
    end

    issues
  end
end
