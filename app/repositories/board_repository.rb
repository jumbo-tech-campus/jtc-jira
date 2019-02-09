class BoardRepository
  def initialize(jira_client)
    @records = {}
    @client = jira_client
  end

  def find_by(options)
    if options[:id]
      return @records[options[:id]] if @records[options[:id]]

      board = load_board(options[:id], options[:subteam])
      board.team = Repository.for(:team).find_by(board_id: options[:id]).first
    elsif options[:team]
      team = options[:team]
      return @records[team.board_id] if @records[team.board_id]

      board = load_board(team.board_id, team.subteam)
      board.team = team
    end
    @records[board.id] ||= board
  end

  private
  def load_board(id, subteam)
    board = Board.from_jira(@client.Board.find(id))
    load_sprints(board, subteam)
    board
  end

  def load_sprints(board, subteam)
    sprints = Repository.for(:sprint).find_by(board: board, subteam: subteam)
    board.sprints.concat(sprints)
  end
end
