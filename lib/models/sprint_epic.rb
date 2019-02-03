class SprintEpic
  attr_reader :sprint, :epic
  attr_accessor :total_points

  def initialize(sprint, epic)
    @sprint, @epic = sprint, epic
    @total_points = 0
  end

  def ==(sprint_epic)
    epic == sprint_epic.epic
  end

  def parent_epic
    epic.parent_epic
  end

  def percentage
    total_points / sprint.points_closed * 100
  end

  def to_s
    "#{epic}, total points: #{total_points}, percentage: #{percentage.round(1)}%"
  end
end
