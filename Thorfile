require 'dotenv/load'

require_relative 'lib/init_repositories'
require_relative 'lib/jira_client'

class Run < Thor
  desc "task", "whatever"
  def task
    board = Repository.for(:board).find(ENV['BOARD_ID'])

    last_sprint = board.last_closed_sprint

    puts "Points closed in sprint: #{last_sprint.points_closed}"
    puts last_sprint.closed_issues
    puts last_sprint.sprint_epics
    puts last_sprint.sprint_parent_epics
  end
end
