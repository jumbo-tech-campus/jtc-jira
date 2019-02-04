require_relative 'sprint_issue_abilities'

class SprintEpic
  attr_reader :epic

  include SprintIssueAbilities

  def initialize(sprint, epic)
    @epic = epic

    sprint_issue_abilities(sprint, [])
  end

  def ==(sprint_epic)
    epic == sprint_epic.epic
  end

  def parent_epic
    epic.parent_epic
  end

  def to_s
    "#{epic}, points closed: #{points_closed}, percentage in sprint: #{percentage_of_points_closed.round(1)}%"
  end
end
