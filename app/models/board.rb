class Board < ActiveModelSerializers::Model
  attr_reader :id, :type
  attr_accessor :team

  def initialize(id, type)
    @id, @type = id, type
  end

  def current_sprint
    sprint_for(Date.today)
  end
end
