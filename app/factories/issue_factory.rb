class IssueFactory
  def create_from_jira(json)
    issue_class = if json['fields']['issuetype']['name'] == 'Incident'
                    Incident
                  elsif json['fields']['issuetype']['name'] == 'Alert'
                    Alert
                  else
                    Issue
                  end

    issue = issue_class.new(json['key'], json['fields']['summary'],
                            json['id'], json['fields']['customfield_10014'] || 0,
                            ApplicationHelper.safe_parse(json['fields']['created']),
                            json['fields']['status']['name'],
                            ApplicationHelper.safe_parse(json['fields']['resolutiondate']),
                            nil, nil, nil, nil)
    issue.assignee = json['fields']['assignee']['displayName'] if json['fields']['assignee']
    issue.resolution = json['fields']['resolution']['name'] if json['fields']['resolution']
    issue.subteam = json['fields']['customfield_12613']['value'] if json['fields']['customfield_12613']
    issue.epic = Repository.for(:epic)&.find(json['fields']['customfield_10016']) if json['fields']['customfield_10016']
    issue.state_changed_events.concat(get_state_changed_events(json))
    json['fields']['labels'].each do |label|
      issue.labels << label
    end
    json['fields']['components'].each do |component|
      issue.components << component['name']
    end
    issue
  end

  def create_from_json(json)
    issue_class = if json['class_name'] == 'Incident'
                    Incident
                  elsif json['class_name'] == 'Alert'
                    Alert
                  else
                    Issue
                  end

    issue = issue_class.new(json['key'], json['summary'],
                            json['id'], json['estimation'],
                            ApplicationHelper.safe_parse(json['created']),
                            json['status'],
                            ApplicationHelper.safe_parse(json['resolution_date']),
                            ApplicationHelper.safe_parse(json['in_progress_date']),
                            ApplicationHelper.safe_parse(json['release_date']),
                            ApplicationHelper.safe_parse(json['pending_release_date']),
                            ApplicationHelper.safe_parse(json['done_date']))
    issue.assignee = json['assignee']
    issue.resolution = json['resolution']
    issue.subteam = json['subteam']
    issue.epic = Factory.for(:epic).create_from_json(json['epic']) if json['epic']
    json['labels'].each do |label|
      issue.labels << label
    end
    json['components'].each do |component|
      issue.components << component
    end

    issue
  end

  private

  def get_state_changed_events(json)
    json['changelog']['histories'].each_with_object([]) do |history, memo|
      history['items'].each do |item|
        if item['fieldId'] == 'status'
          memo << Factory.for(:state_changed_event).create_from_jira(history)
          break
        end
      end
    end.sort_by(&:created)
  end
end
