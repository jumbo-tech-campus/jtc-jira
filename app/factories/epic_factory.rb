class EpicFactory
  def create_from_jira(issue)
    epic = Epic.new(issue.key, issue.summary, issue.id.to_i, issue.fields['customfield_10018'])
    if issue.fields['customfield_11200']['data']
      epic.parent_epic = Repository.for(:parent_epic).find(issue.fields['customfield_11200']['data']['key'])
    end
    epic
  end

  def create_from_json(json)
    return nil if json.nil?

    epic = Epic.new(json['key'], json['summary'], json['id'], json['name'])
    epic.parent_epic = Factory.for(:parent_epic).create_from_json(json['parent_epic'])
    epic
  end
end
