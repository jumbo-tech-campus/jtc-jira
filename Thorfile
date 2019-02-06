require 'dotenv/load'
require_relative 'lib/command_line'
require_relative 'config/environment.rb'

class Report < Thor
  desc "last_sprint", "Report statistics on last closed sprint for specified board id"
  method_option :board_id, type: :numeric
  method_option :number_of_sprints, type: :numeric
  method_option :subteam
  def last_sprint
    command_line = CommandLine.new
    command_line.print_last_sprints(options[:board_id], options[:subteam], options[:number_of_sprints])
  end

  desc "last_sprint_from_config", "Report statistics on last closed sprint for teams from config file"
  def last_sprint_from_config
    team_config = YAML.load_file('config.yaml')
    command_line = CommandLine.new
    team_config.each do |options|
      command_line.print_last_sprints(options[:board_id], options[:subteam], 1)
    end
  end

  desc "open_sprint", "Report statistics on open sprint for specified board id"
  method_option :board_id, type: :numeric
  method_option :subteam
  def open_sprint
    command_line = CommandLine.new
    command_line.print_open_sprint(options[:board_id], options[:subteam])
  end
end
