require 'dotenv/load'

require_relative 'lib/config'
require_relative 'lib/jira_client'

class Report < Thor
  desc "last_sprint", "Report statistics on last closed sprint for specified board id"
  method_option :board_id, type: :numeric
  method_option :subteam
  def last_sprint
    config = Config.new(options[:subteam])
    puts options[:subteam]
    config.init_repositories

    board = Repository.for(:board).find(options[:board_id])

    last_sprint = board.last_closed_sprint

    puts last_sprint
    puts last_sprint.closed_issues
    puts last_sprint.sprint_epics
    puts last_sprint.sprint_parent_epics
  end
end
