module SprintIssueAbilities
  attr_reader :issues, :sprint

  def sprint_issue_abilities(sprint, issues)
    @sprint = sprint
    @issues = issues
  end

  def percentage_of_points_closed
    return 0 if sprint.points_closed == 0

    points_closed / sprint.points_closed.to_f * 100
  end

  def percentage_of_issues_closed
    return 0 if issues.size == 0

    closed_issues.size / issues.size.to_f * 100
  end

  def wbso_percentage_of_issues_closed
    return 0 if sprint.points_closed == 0

    wbso_points_closed / sprint.points_closed.to_f * 100
  end

  def closed_issues
    issues.select{ |issue| closed_in_sprint?(issue) }
  end

  def open_issues
    issues.select{ |issue| !closed_in_sprint?(issue) }
  end

  def wbso_issues
    issues.select{ |issue| issue.parent_epic&.wbso_project.present? }
  end

  def issues_per_wbso_project
    wbso_issues.inject({}) do |memo, issue|
      wbso_project = issue.epic.parent_epic.wbso_project
      if memo[wbso_project]
        memo[wbso_project] << issue
      else
        memo[wbso_project] = [issue]
      end
      memo
    end
  end

  def closed_in_sprint?(issue)
    issue.resolution_date && issue.resolution_date <= (sprint.complete_date || sprint.end_date)
  end

  def points_closed
    closed_issues.reduce(0){ |sum, issue| sum + (issue.estimation || 0) }
  end

  def points_open
    open_issues.reduce(0){ |sum, issue| sum + (issue.estimation || 0) }
  end

  def points_total
    issues.reduce(0){ |sum, issue| sum + (issue.estimation || 0) }
  end

  def wbso_points_closed
    wbso_issues.reduce(0) do |sum, issue|
      if closed_in_sprint?(issue)
        sum += issue.estimation
      end
      sum
    end
  end

  def wbso_percentage_of_points_closed_per_wbso_project
    issues_per_wbso_project.inject({}) do |memo, (wbso_project, issues)|
      total = issues.reduce(0) do |sum, issue|
        if closed_in_sprint?(issue)
          sum += issue.estimation
        end
        sum
      end
      memo[wbso_project] = total  / points_closed.to_f * 100
      memo
    end
  end
end
