class BoardFactory
  def create_from_jira(board)
    Board.new(board.name, board.id)
  end

  def create_from_json(json)
    board = Board.new(json['name'], json['id'])
    board.team = Factory.for(:team).create_from_json(json['team'])
    json['sprints'].each do |sprint_json|
      board.sprints << Factory.for(:sprint).create_from_json(sprint_json, board)
    end
    board
  end
end
