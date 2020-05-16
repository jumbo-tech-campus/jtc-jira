class AlertFactory < IssueFactory
  def create_from_jira(json)
    alert = super
    alert.alerted_at = ApplicationHelper.safe_parse_epoch(json['fields']['customfield_12882'])&.beginning_of_minute
    alert.event_key = json['fields']['customfield_12883']
    alert
  end

  def create_from_json(json)
    alert = super
    alert.alerted_at = ApplicationHelper.safe_parse(json['alerted_at'])
    alert.event_key = json['event_key']
    alert
  end
end
