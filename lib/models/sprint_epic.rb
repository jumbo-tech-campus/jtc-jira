class SprintEpic
  attr_reader :sprint, :epic
  attr_accessor :points_closed

  def initialize(sprint, epic)
    @sprint, @epic = sprint, epic
    @points_closed = 0
  end

  def ==(sprint_epic)
    epic == sprint_epic.epic
  end

  def parent_epic
    epic.parent_epic
  end

  def percentage_of_points_closed
    points_closed / sprint.points_closed * 100
  end

  def to_s
    "#{epic}, points closed: #{points_closed}, percentage in sprint: #{percentage_of_points_closed.round(1)}%"
  end
end
