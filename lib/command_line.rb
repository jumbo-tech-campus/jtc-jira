require_relative 'config'
require_relative 'jira_client'

class CommandLine
  def print_last_sprint(board_id, subteam)
    puts "Report for board #{board_id} #{subteam}"
    config = Config.new(subteam)
    config.init_repositories

    board = Repository.for(:board).find(board_id)

    last_sprint = board.last_closed_sprint

    puts last_sprint
    puts last_sprint.closed_issues
    puts last_sprint.sprint_epics
    puts last_sprint.sprint_parent_epics
  end
end
