class Board < ActiveModelSerializers::Model
  attr_reader :id, :type
  attr_accessor :team, :project

  def initialize(id, type)
    @id, @type = id, type
  end
end
