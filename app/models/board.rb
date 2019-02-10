class Board < ActiveModelSerializers::Model
  attr_reader :name, :id, :sprints
  attr_accessor :team

  def initialize(name, id)
    @name, @id = name, id
    @sprints = []
  end

  def self.from_jira(board)
    new(board.name, board.id)
  end

  def self.from_cache(json)
    board = new(json['name'], json['id'])
    board.team = Team.from_cache(json['team'])
    json['sprints'].each do |sprint_json|
      board.sprints << Sprint.from_cache(sprint_json)
    end
    board
  end

  def closed_sprints
    sprints.select{ |sprint| sprint.closed? }
  end

  def open_sprint
    sprints.select{ |sprint| !sprint.closed? }.first
  end

  def recent_closed_sprints(n)
    closed_sprints.sort_by{ |sprint| sprint.end_date }.reverse.take(n)
  end

  def recent_sprints(n)
    sprints.sort_by{ |sprint| sprint.end_date }.reverse.take(n)
  end

  def last_closed_sprint
    recent_closed_sprints(1).first
  end

  def to_s
    "Name: #{name}, id: #{id}, number of sprints: #{sprints.size}, number of closed sprints: #{closed_sprints.size}"
  end
end
