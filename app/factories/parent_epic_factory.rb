class ParentEpicFactory
  def create_from_jira(jira_epic)
    wbso_project = jira_epic['fields']['customfield_12834']['value'] if jira_epic['fields']['customfield_12834'] && jira_epic['fields']['customfield_12834']['id'] != '11436'
    fix_version = json['fields']['fixVersions'].last['name'] if json['fields']['fixVersions'].any?

    ParentEpic.new(json['id'].to_i, json['key'], json['fields']['summary'] || json['summary'], wbso_project, fix_version)
  end

  def create_from_json(json)
    return nil if json.nil?

    ParentEpic.new(json['id'], json['key'], json['summary'], json['wbso_project'], json['fix_version'])
  end
end
