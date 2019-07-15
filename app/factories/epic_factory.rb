class EpicFactory
  def create_from_jira(json)
    epic = Epic.new(json['key'], json['fields']['summary'],
      json['id'].to_i, json['fields']['customfield_10018'],
      json['fields']['status']['name']
    )
    if json['fields']['customfield_11200']['data']
      epic.parent_epic = Repository.for(:parent_epic).find(json['fields']['customfield_11200']['data']['key'])
    end
    epic
  end

  def create_from_json(json)
    return nil if json.nil?

    epic = Epic.new(json['key'], json['summary'], json['id'], json['name'], json['status'])
    epic.parent_epic = Factory.for(:parent_epic).create_from_json(json['parent_epic'])
    epic
  end
end
