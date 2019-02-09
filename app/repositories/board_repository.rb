class BoardRepository
  def initialize(jira_client)
    @records = {}
    @client = jira_client
  end

  def find_by(options)
    if options[:id]
      @records[options[:id]] ||= load_board(options[:id], options[:subteam])
    elsif options[:team]
      @records[options[team].board_id] ||= load_board(options[:team].board_id, options[:team].subteam)
    end
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
