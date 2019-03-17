module Cache
  class BoardRepository
    def initialize(client)
      @client = Cache::RedisClient.new
      @records = {}
    end

    def find(id)
      @records[id] ||= Factory.for(:board).create_from_json(JSON.parse(@client.get("board.#{id}")))
    end

    def save(board)
      if board.is_a? ScrumBoard
        included = ['team.**', 'sprints']
      elsif board.is_a? KanbanBoard
        included = ['team.**', 'issues']
      end

      @client.set("board.#{board.id}", ActiveModelSerializers::SerializableResource.new(board, include: included).to_json)
    end
  end
end
