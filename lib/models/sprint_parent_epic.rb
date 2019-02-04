class SprintParentEpic
  attr_reader :sprint, :parent_epic
  attr_accessor :points_closed

  def initialize(sprint, parent_epic)
    @sprint, @parent_epic = sprint, parent_epic
    @points_closed = 0
  end

  def ==(sprint_parent_epic)
    self.parent_epic == sprint_parent_epic.parent_epic
  end

  def percentage_of_points_closed
    points_closed / sprint.points_closed * 100
  end

  def to_s
    "#{parent_epic}, points closed: #{points_closed}, percentage in sprint: #{percentage_of_points_closed.round(1)}%"
  end
end
