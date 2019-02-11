module Jira
  class SprintRepository < Jira::JiraRepository
    def find_by(options)
      if options[:board]
        find_by_board(options[:board], options[:subteam])
      elsif options[:id]
        find_by_id(options[:id], options[:subteam])
      end
    end

    private
    def find_by_board(board, subteam)
      start_at = 0
      sprints = []

      loop do
        response = @client.Agile.get_sprints(board.id, {startAt: start_at})

        response['values'].each do |value|
          sprint = Factory.for(:sprint).create_from_jira(value)
          #skip future sprints
          next unless sprint.start_date

          sprint.subteam = subteam
          sprints << sprint
          @records[sprint.id] = sprint
        end

        start_at += response['maxResults']
        break if response['isLast']
      end
      sprints
    end

    def find_by_id(id, subteam)
      sprint = @records[id]

      return sprint unless sprint.nil?

      begin
        json = @client.Sprint.find(id).to_json
        sprint = Factory.for(:sprint).create_from_jira(json)
        sprint.subteam = subteam
      rescue JIRA::HTTPError
        # apparently sprint was deleted
        sprint = Sprint.new(id, 'Deleted sprint', 'closed', nil, nil, nil)
      end

      @records[id] = sprint
      sprint
    end
  end
end
