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

  def print_open_sprint(board_id, subteam)
    puts "Report for board #{board_id} #{subteam}"
    config = Config.new(subteam)
    config.init_repositories

    board = Repository.for(:board).find(board_id)

    open_sprint = board.open_sprint

    if open_sprint.nil?
      puts "No open sprint"
      exit(0)
    end

    puts open_sprint
    puts "Closed issues:"
    puts open_sprint.closed_issues
    puts "Open issues:"
    puts open_sprint.open_issues

    puts open_sprint.sprint_epics
    puts open_sprint.sprint_parent_epics
  end
end
