class KanbanBoard < Board
  attr_reader :issues

  def initialize(*args)
    super
    @issues = []
  end

  def sprint_for(date)
    start_date = date.beginning_of_week
    end_date = start_date + 2.weeks

    sprint = KanbanSprint.new(0, "Sprint #{start_date.cweek} #{start_date.year}", "", start_date, end_date, end_date)
    sprint.board = self
    sprint
  end
end
