module Cache
  class BoardRepository < Cache::CacheRepository
    def find(id)
      return @records[id] if @records[id]

      board_json = @client.get("board.#{id}")

      if board_json
        @records[id] = Factory.for(:board).create_from_json(JSON.parse(board_json))
      else
        Rails.logger.error("No board found for id: #{id}")
        nil
      end
    end

    def save(board)
      if board.is_a? ScrumBoard
        included = ['project', 'sprints']
      elsif board.is_a? KanbanBoard
        included = ['project', 'issues', 'issues.epic', 'issues.epic.parent_epic']
      end

      @client.set("board.#{board.id}", ActiveModelSerializers::SerializableResource.new(board, include: included).to_json)
    end
  end
end
