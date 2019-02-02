require 'dotenv/load'
require_relative 'lib/jira_client'

class Run < Thor
  desc "task", "whatever"
  def task
    client = JiraClient.new()
    board = client.get_board_by_id(ENV['BOARD_ID'])

    last_sprint = board.last_closed_sprint
    last_sprint.issues.concat(client.get_issues_for(last_sprint))

    puts "Points closed in sprint: #{last_sprint.points_closed}"
    puts last_sprint.closed_issues
    puts last_sprint.sprint_epics
  end
end
