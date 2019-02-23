class StateChangedEventFactory
  def create_from_jira(json)
    state_changed_item = json['items'].select{ |item| item['fieldId'] == 'status' }.first

    StateChangedEvent.new(ApplicationHelper.safe_parse(json['created']),
      state_changed_item['fromString'],
      state_changed_item['toString']
    )
  end
end
