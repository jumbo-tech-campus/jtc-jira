require 'jira-ruby'
require_relative 'board'
require_relative 'sprint'

class JiraClient
  extend Forwardable

  def initialize
    options = {
      :username     => ENV['USERNAME'],
      :password     => ENV['API_KEY'],
      :site         => ENV['SITE'],
      :context_path => '',
      :auth_type    => :basic
    }

    @client = JIRA::Client.new(options)
  end

  def get_board_by_id(board_id)
    response = @client.Board.find(board_id)

    board = Board.create_from(response)
    board.sprints.concat(get_sprints_for(board))

    board
  end

  def get_sprints_for(board)
    start_at = 0
    sprints = []

    loop do
      response = @client.Agile.get_sprints(board.id, {startAt: start_at})

      response['values'].each do |sprint|
        sprint.transform_keys!(&:to_sym)
        sprints << Sprint.new(sprint)
      end

      start_at += response['maxResults']
      break if response['isLast']
    end
    sprints
  end
end
