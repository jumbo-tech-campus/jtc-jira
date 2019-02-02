require 'dotenv/load'
require_relative 'lib/jira_client'
require_relative 'lib/sprint'

class Run < Thor
  desc "task", "whatever"
  def task
    client = JiraClient.new()
    board = client.get_board_by_id(ENV['BOARD_ID'])

    puts board.recent_closed_sprints(5)
  end
end
