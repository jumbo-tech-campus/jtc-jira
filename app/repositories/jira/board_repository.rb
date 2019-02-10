module Jira
  class BoardRepository < Jira::JiraRepository
    def find(id)
      return @records[id] if @records[id]

      team = Repository.for(:team).find_by(board_id: id).first
      board = load_board(id, team.subteam)
      board.team = team
      @records[board.id] ||= board
    end

    def find_by(options)
      if options[:team]
        team = options[:team]
        return @records[team.board_id] if @records[team.board_id]

        board = load_board(team.board_id, team.subteam)
        board.team = team
        @records[board.id] ||= board
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
end
