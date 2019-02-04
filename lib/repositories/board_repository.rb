require_relative '../models/board'
require_relative '../jira_client'
require_relative 'repository'

class BoardRepository
  def initialize(jira_client)
    @records = {}
    @client = jira_client
  end

  def find(id)
    @records[id] ||= load_board(id)
  end

  private
  def load_board(id)
    board = Board.from_jira(@client.Board.find(id))
    load_sprints(board)
    board
  end

  def load_sprints(board)
    sprints = Repository.for(:sprint).find_by(board: board)
    board.sprints.concat(sprints)
  end
end
