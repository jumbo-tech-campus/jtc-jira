class BoardFactory
  def create_from_jira(board)
    if board.type == 'scrum'
      ScrumBoard.new(board.id, board.type)
    elsif board.type == 'kanban'
      KanbanBoard.new(board.id, board.type)
    end
  end

  def create_from_json(json)
    if json['type'] == 'scrum'
      board = ScrumBoard.new(json['id'], json['type'])
      json['sprints'].each do |sprint_json|
        board.sprints << Factory.for(:sprint).create_from_json(sprint_json, board)
      end
    elsif json['type'] == 'kanban'
      board = KanbanBoard.new(json['id'], json['type'])
      json['issues'].each do |issue|
        board.issues << Factory.for(:issue).create_from_json(issue)
      end
    end

    board.team = Factory.for(:team).create_from_json(json['team'])

    board
  end
end
