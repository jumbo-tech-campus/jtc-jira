class Board < ActiveModelSerializers::Model
  attr_reader :id, :type, :sprints
  attr_accessor :project

  def initialize(id, type)
    @id, @type = id, type
    @sprints = []
  end

  def closed_sprints
    sprints.select(&:closed?)
  end

  def open_sprints
    sprints.select(&:open?)
  end
end
