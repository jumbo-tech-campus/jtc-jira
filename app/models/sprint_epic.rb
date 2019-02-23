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

  def description
    epic.description
  end

  def parent_epic
    epic.parent_epic
  end
end
