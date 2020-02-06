class ParentEpicFactory
  def create_from_jira(json)
    wbso_project = json['fields']['customfield_12834']['value'] if json['fields']['customfield_12834'].present? && json['fields']['customfield_12834']['id'] != '11436'
    assignee = json['fields']['assignee']['displayName'] if json['fields']['assignee']

    parent_epic = ParentEpic.new(json['id'].to_i, json['key'],
      json['fields']['summary'], wbso_project,
      assignee, json['fields']['status']['name']
    )

    json['fields']['fixVersions'].each do |fix_version|
      parent_epic.fix_versions << fix_version['name']
    end

    parent_epic
  end

  def create_from_json(json)
    return nil if json.nil?

    parent_epic = ParentEpic.new(json['id'], json['key'], json['summary'],
      json['wbso_project'], json['assignee'], json['status']
    )
    json['epics'].each do |epic_json|
      parent_epic.epics << Factory.for(:epic).create_from_json(epic_json)
    end if json['epics']

    json['fix_versions'].each do |fix_version|
      parent_epic.fix_versions << fix_version
    end

    parent_epic
  end
end
