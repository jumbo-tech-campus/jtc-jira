module Jira
  class BoardRepository < Jira::JiraRepository
    def find(id)
      return @records[id] if @records[id]

      board = Factory.for(:board).create_from_jira(@client.Board.find(id))
      @records[id] = board
    end

    def find_by(options)
      if options[:team]
        team = options[:team]
        return @records[team.board_id] if @records[team.board_id]

        board = Factory.for(:board).create_from_jira(@client.Board.find(team.board_id))
        @records[board.id] = board
      end
    end
  end
end
