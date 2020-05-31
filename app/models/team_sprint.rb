class TeamSprint
  extend Forwardable
  attr_reader :team, :sprint
  include SprintIssueAbilities

  def initialize(team, sprint)
    @team, @sprint = team, sprint

    sprint_issue_abilities(sprint, filtered_issues)
  end

  def self.for(date, team)
    sprint = filter_sprints(team.board.sprints_for(date), team).first
    new(team, sprint)
  end

  def self.all(team)
    sprints = filter_sprints(team.board.sprints, team)
    sprints.map{ |sprint| new(team, sprint) }
  end

  def self.last_closed(team)
    sprint = filter_sprints(team.board.closed_sprints, team).sort_by(&:end_date).reverse.first
    new(team, sprint)
  end

  def self.from(year, team)
    sprints = filter_sprints(team.board.sprints_from(year), team)
    sprints.map{ |sprint| new(team, sprint) }
  end

  def sprint_epics
    return @sprint_epics if @sprint_epics

    no_sprint_epic = SprintEpic.new(self, Epic.new('DEV', 'Issues without epic', 0, 'Issues without epic', nil))

    @sprint_epics = issues.inject([]) do |memo, issue|
      if issue.epic
        sprint_epic = SprintEpic.new(self, issue.epic)
        if memo.include?(sprint_epic)
          sprint_epic = memo[memo.index(sprint_epic)]
        else
          memo << sprint_epic
        end
      else
        sprint_epic = no_sprint_epic
      end
      sprint_epic.issues << issue

      memo
    end

    @sprint_epics << no_sprint_epic if no_sprint_epic.issues.size > 0
    @sprint_epics
  end

  def sprint_parent_epics
    return @sprint_parent_epics if @sprint_parent_epics

    no_sprint_parent_epic = SprintParentEpic.new(self, ParentEpic.new(0, 'DEV', 'Issues without portfolio epic', nil, nil, nil))

    @sprint_parent_epics = sprint_epics.inject([]) do |memo, sprint_epic|
      if sprint_epic.parent_epic
        sprint_parent_epic = SprintParentEpic.new(self, sprint_epic.parent_epic)
        if memo.include?(sprint_parent_epic)
          sprint_parent_epic = memo[memo.index(sprint_parent_epic)]
        else
          memo << sprint_parent_epic
        end
      else
        sprint_parent_epic = no_sprint_parent_epic
      end
      sprint_parent_epic.issues.concat(sprint_epic.issues)
      memo
    end

    @sprint_parent_epics << no_sprint_parent_epic if no_sprint_parent_epic.issues.size > 0
    @sprint_parent_epics
  end

  def ==(team_sprint)
    self.sprint == team_sprint.sprint && self.team == team_sprint.team
  end

  def_delegators :@sprint, :id, :closed?, :name, :state, :start_date, :end_date, :complete_date

  private
  def self.filter_sprints(sprints, team)
    if team.filter_sprints_by_team_name
      sprints.select { |sprint| sprint.name.downcase.include?(self.name.downcase) }
    else
      sprints
    end
  end

  def filtered_issues
    if team.subteam
      sprint.issues.select { |issue| issue.subteam == team.subteam }
    elsif team.component
      sprint.issues.select { |issue| issue.components.include?(team.component) }
    else
      sprint.issues
    end
  end
end
