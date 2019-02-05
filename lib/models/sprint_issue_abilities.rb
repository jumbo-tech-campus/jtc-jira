module SprintIssueAbilities
  attr_reader :issues, :sprint

  def sprint_issue_abilities(sprint, issues)
    @sprint = sprint
    @issues = issues
  end

  def percentage_of_points_closed
    return 0 if sprint.points_closed == 0

    points_closed / sprint.points_closed * 100
  end

  def closed_issues
    issues.select{ |issue| closed_in_sprint?(issue) }
  end

  def open_issues
    issues.select{ |issue| !closed_in_sprint?(issue) }
  end

  def closed_in_sprint?(issue)
    issue.resolution_date && issue.resolution_date <= (sprint.complete_date || sprint.end_date)
  end

  def points_closed
    closed_issues.reduce(0){ |sum, issue| sum + issue.estimation }
  end

  def points_open
    open_issues.reduce(0){ |sum, issue| sum + issue.estimation }
  end

  def points_total
    issues.reduce(0){ |sum, issue| sum + issue.estimation }
  end
end
