require_relative '../models/board'
require_relative '../jira_client'
require_relative 'repository'

class BoardRepository
  def initialize
    @records = {}
    @client = JiraClient.new
  end

  def find(id)
    @records[id] ||= load_board(id)
  end

  private
  def load_board(id)
    Board.from_jira_board(@client.Board.find(id))
  end
end
