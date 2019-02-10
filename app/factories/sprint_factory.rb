class SprintFactory
  def create_from_jira(json)
    Sprint.new(json['id'].to_i, json['name'], json['state'],
      ApplicationHelper.safe_parse(json['startDate']),
      ApplicationHelper.safe_parse(json['endDate']),
      ApplicationHelper.safe_parse(json['completeDate'])
    )
  end

  def create_from_json(json)
    sprint = Sprint.new(json['id'].to_i, json['name'], json['state'],
      ApplicationHelper.safe_parse(json['start_date']),
      ApplicationHelper.safe_parse(json['end_date']),
      ApplicationHelper.safe_parse(json['complete_date'])
    )
    sprint.subteam = json['subteam']
    sprint
  end
end
