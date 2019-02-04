class SprintParentEpic
  attr_reader :sprint, :parent_epic
  attr_accessor :total_points

  def initialize(sprint, parent_epic)
    @sprint, @parent_epic = sprint, parent_epic
    @total_points = 0
  end

  def ==(sprint_parent_epic)
    self.parent_epic == sprint_parent_epic.parent_epic
  end

  def percentage
    total_points / sprint.points_closed * 100
  end

  def to_s
    "#{parent_epic}, total points: #{total_points}, percentage: #{percentage.round(1)}%"
  end
end
