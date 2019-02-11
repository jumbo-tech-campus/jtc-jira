class SprintChangeEventFactory
  def create_from_jira(json, issue)
    to_sprint_id = json['items'].first['to'].split(',').last.to_i
    to_sprint  = Repository.for(:sprint).find_by(id: to_sprint_id) unless to_sprint_id == 0
    SprintChangeEvent.new(json['id'], ApplicationHelper.safe_parse(json['created']),
      to_sprint,
      issue
    )
  end
end
