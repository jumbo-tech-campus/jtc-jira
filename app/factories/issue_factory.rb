class IssueFactory
  def create_from_jira(json)
    return Factory.for(:parent_epic).create_from_jira(json) if json['fields']['issuetype']['id'] == '10600'

    issue = Issue.new(json['key'], json['fields']['summary'],
      json['id'], json['fields']['customfield_10014'] || 0,
      ApplicationHelper.safe_parse(json['fields']['created']),
      json['fields']['status']['name'],
      ApplicationHelper.safe_parse(json['fields']['resolutiondate']),
      nil, nil, nil
    )
    issue.assignee = json['fields']['assignee']['displayName'] if json['fields']['assignee']
    issue.epic = Repository.for(:epic).find(json['fields']['epic']['key']) if json['fields']['epic']
    issue.state_changed_events.concat(get_state_changed_events(json))

    issue
  end

  def create_from_json(json)
    return Factory.for(:parent_epic).create_from_json(json) if json.has_key?('wbso_project')

    issue = Issue.new(json['key'], json['summary'],
      json['id'], json['estimation'],
      ApplicationHelper.safe_parse(json['created']),
      json['status'],
      ApplicationHelper.safe_parse(json['resolution_date']),
      ApplicationHelper.safe_parse(json['in_progress_date']),
      ApplicationHelper.safe_parse(json['done_date']),
      ApplicationHelper.safe_parse(json['ready_for_prod_date'])
    )
    issue.assignee = json['assignee']
    issue.epic = Factory.for(:epic).create_from_json(json['epic'])
    issue
  end

  private
  def get_state_changed_events(json)
    json['changelog']['histories'].inject([]) do |memo, history|
      history['items'].each do |item|
        if item['fieldId'] == 'status'
          memo << Factory.for(:state_changed_event).create_from_jira(history)
          break
        end
      end
      memo
    end.sort_by{ |event| event.created }
  end
end
