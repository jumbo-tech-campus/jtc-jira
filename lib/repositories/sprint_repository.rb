require_relative '../models/sprint'

class SprintRepository
  def initialize(jira_client)
    @records = {}
    @client = jira_client
  end

  def find(id)
    sprint = @records[id]

    return sprint unless sprint.nil?

    begin
      sprint = Sprint.from_jira(@client.Sprint.find(id).to_json)
    rescue JIRA::HTTPError
      # apparently sprint was deleted
      sprint = Sprint.new(id, 'Deleted sprint', 'closed', nil, nil, nil)
    end

    @records[id] = sprint
    sprint
  end

  def find_by(options)
    if options[:board]
      find_by_board(options[:board])
    end
  end

  private
  def find_by_board(board)
    start_at = 0
    sprints = []

    loop do
      response = @client.Agile.get_sprints(board.id, {startAt: start_at})

      response['values'].each do |value|
        sprint = Sprint.from_jira(value)
        sprints << sprint
        @records[sprint.id] = sprint
      end

      start_at += response['maxResults']
      break if response['isLast']
    end
    sprints
  end
end
