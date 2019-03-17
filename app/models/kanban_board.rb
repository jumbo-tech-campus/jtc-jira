class KanbanBoard < Board
  attr_reader :issues

  def initialize(*args)
    super
    @issues = []
  end
end
