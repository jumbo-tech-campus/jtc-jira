class CommandLine
  def print_last_sprints(board_id, subteam, number_of_sprints)
    puts "Report for board #{board_id} #{subteam}"

    board = Repository.for(:board).find(board_id)

    last_sprints = board.recent_closed_sprints(number_of_sprints)

    last_sprints.each do |last_sprint|
      puts last_sprint
      puts "Closed issues:"
      puts last_sprint.closed_issues
      puts "Open issues:"
      puts last_sprint.open_issues
      puts "Added issues"
      puts last_sprint.issues_added_after_start
      puts last_sprint.sprint_epics
      puts last_sprint.sprint_parent_epics
    end
  end

  def print_open_sprint(board_id, subteam)
    puts "Report for board #{board_id} #{subteam}"

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
