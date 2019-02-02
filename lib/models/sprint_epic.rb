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

  def name
    epic&.name || "No epic"
  end

  def percentage
    total_points / sprint.points_closed * 100
  end

  def to_s
    "Epic: #{name}, total points: #{total_points}, percentage: #{percentage.round(1)}%"
  end
end
