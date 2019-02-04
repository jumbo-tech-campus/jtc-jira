require_relative 'sprint_issue_abilities'

class SprintParentEpic
  attr_reader :parent_epic

  include SprintIssueAbilities

  def initialize(sprint, parent_epic)
    @parent_epic = parent_epic

    sprint_issue_abilities(sprint, [])
  end

  def ==(sprint_parent_epic)
    self.parent_epic == sprint_parent_epic.parent_epic
  end

  def to_s
    if sprint.closed?
      "#{parent_epic}, points closed: #{points_closed}, percentage in sprint: #{percentage_of_points_closed.round(1)}%"
    else
      "#{parent_epic}, points closed: #{points_closed}, points open: #{points_open}"
    end
  end
end
