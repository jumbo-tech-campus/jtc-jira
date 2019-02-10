class EpicFactory
  def create_from_jira(issue)
    epic = Epic.new(issue.key, issue.summary, issue.id.to_i, issue.fields['customfield_10018'])
    epic.parent_epic = Factory.for(:parent_epic).create_from_jira(issue.fields['customfield_11200']['data'])
    epic
  end

  def create_from_json(json)
    return nil if json.nil?

    epic = Epic.new(json['key'], json['summary'], json['id'], json['name'])
    epic.parent_epic = Factory.for(:parent_epic).create_from_json(json['parent_epic'])
    epic
  end
end
