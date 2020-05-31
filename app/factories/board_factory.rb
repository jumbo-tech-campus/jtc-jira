class BoardFactory
  def create_from_jira(jira_board)
    return nil unless jira_board.respond_to? :type

    if jira_board.type == 'scrum'
      board = ScrumBoard.new(jira_board.id, jira_board.type)
      sprints = Repository.for(:sprint).find_by(board: board)
      board.sprints.concat(sprints)
    elsif jira_board.type == 'kanban'
      board = KanbanBoard.new(jira_board.id, jira_board.type)
      # it seems that tickets are only associated to a KanbanBoard when they are on the board
      # we need to have more history around this - also report on tickets that were on the board at some point
      # we also see that teams switch from Scrum to Kanban, making it hard to report on historical data
      # this aims to fix that by retrieving all issues from a project instead of the board
      # TODO: also do this for teams that work in sprints
      issues = Repository.for(:issue).find_by(project_key: jira_board.attrs['location']['projectKey'])
      board.issues.concat(issues)
    end
    board.project = Repository.for(:project).find(jira_board.attrs['location']['projectKey'])

    board
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
    board.project = Factory.for(:project).create_from_json(json['project'])

    board
  end
end
