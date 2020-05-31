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

  def description
    parent_epic.description
  end
end
