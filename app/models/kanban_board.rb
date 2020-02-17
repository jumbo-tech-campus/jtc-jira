class KanbanBoard < Board
  attr_reader :issues

  def initialize(*args)
    super
    @issues = []
  end

  def sprint_for(date)
    nil
  end
end
