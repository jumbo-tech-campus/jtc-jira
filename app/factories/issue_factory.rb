class IssueFactory
  def create_from_jira(json)
    Issue.new(json['key'], json['fields']['summary'],
      json['id'], json['fields']['customfield_10014'] || 0,
      ApplicationHelper.safe_parse(json['fields']['created']),
      ApplicationHelper.safe_parse(json['fields']['resolutiondate'])
    )
  end

  def create_from_json(json)
    issue = Issue.new(json['key'], json['summary'],
      json['id'], json['estimation'],
      ApplicationHelper.safe_parse(json['created']),
      ApplicationHelper.safe_parse(json['resolution_date'])
    )
    issue.epic = Factory.for(:epic).create_from_json(json['epic'])
    issue
  end
end
