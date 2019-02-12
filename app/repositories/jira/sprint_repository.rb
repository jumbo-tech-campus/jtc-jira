module Jira
  class SprintRepository < Jira::JiraRepository
    def find_by(options)
      if options[:board]
        find_by_board(options[:board])
      elsif options[:id]
        find_by_id(options[:id], options[:board])
      end
    end

    private
    def find_by_board(board)
      start_at = 0
      sprints = []

      loop do
        response = @client.Agile.get_sprints(board.id, {startAt: start_at})

        response['values'].each do |value|
          sprint = Factory.for(:sprint).create_from_jira(value)
          #skip future sprints
          next unless sprint.start_date

          sprint.board = board
          sprints << sprint
          @records[uid(sprint.id, board)] = sprint
        end

        start_at += response['maxResults']
        break if response['isLast']
      end
      sprints
    end

    def find_by_id(id, board)
      sprint = @records[uid(id, board)]

      return sprint unless sprint.nil?

      begin
        json = @client.Sprint.find(id).to_json
        sprint = Factory.for(:sprint).create_from_jira(json)
        sprint.board = board
      rescue JIRA::HTTPError
        # apparently sprint was deleted
        sprint = Sprint.new(id, 'Deleted sprint', 'closed', nil, nil, nil)
      end

      @records[uid(id, board)] = sprint
      sprint
    end

    private
    def uid(id, board)
      options[:board].id.to_s << '_' << options[:id].to_s
    end
  end
end
