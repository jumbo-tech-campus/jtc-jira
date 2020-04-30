class IncidentFactory < IssueFactory
  def create_from_jira(json)
    incident = super
    incident.start_date = ApplicationHelper.safe_parse(json['fields']['customfield_12878'])
    incident.end_date = ApplicationHelper.safe_parse(json['fields']['customfield_12879'])
    incident.reported_date = ApplicationHelper.safe_parse(json['fields']['customfield_12881'])
    json['fields']['customfield_12880'].each do |cause|
      incident.causes << cause['value']
    end if json['fields']['customfield_12880']
    incident
  end

  def create_from_json(json)
    incident = super
    incident.start_date = ApplicationHelper.safe_parse(json['start_date'])
    incident.end_date = ApplicationHelper.safe_parse(json['end_date'])
    incident.reported_date = ApplicationHelper.safe_parse(json['reported_date'])
    json['causes'].each do |cause|
      incident.causes << cause
    end
    incident
  end
end
