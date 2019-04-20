class ParentEpicFactory
  def create_from_jira(jira_epic)
    wbso_project = jira_epic.fields['customfield_12834']['value'] if jira_epic.fields['customfield_12834'] && jira_epic.fields['customfield_12834']['id'] != '11436'
    ParentEpic.new(jira_epic.id.to_i, jira_epic.key, jira_epic.summary, wbso_project)
  end

  def create_from_json(json)
    return nil if json.nil?

    ParentEpic.new(json['id'], json['key'], json['summary'], json['wbso_project'])
  end
end
