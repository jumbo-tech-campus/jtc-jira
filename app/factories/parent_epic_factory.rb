class ParentEpicFactory
  def create_from_jira(json)
    return nil if json.nil?

    ParentEpic.new(json['id'], json['key'], json['summary'])
  end

  def create_from_json(json)
    return nil if json.nil?

    ParentEpic.new(json['id'], json['key'], json['summary'])
  end
end
