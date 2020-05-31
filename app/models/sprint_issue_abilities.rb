module SprintIssueAbilities
  attr_reader :issues, :sprint

  def sprint_issue_abilities(sprint, issues)
    @sprint = sprint
    @issues = issues
  end

  def percentage_closed
    return 0 if points_total == 0

    points_closed / sprint.points_total.to_f * 100
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

  def released_issues
    issues.select{ |issue| released_in_sprint?(issue) }
  end

  def rejected_issues
    issues.select{ |issue| issue.rejected? }
  end

  def resolved_issues
    closed_issues + rejected_issues
  end

  def done_issues
    issues.inject([]) do |memo, issue|
      memo << issue if issue.release_date.present? && issue.release_date.between?(sprint.start_date, sprint.complete_date || sprint.end_date)
      memo
    end
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
    issue.closed? && issue.resolution_date <= (sprint.complete_date || sprint.end_date)
  end

  def released_in_sprint?(issue)
    issue.released? && issue.release_date <= (sprint.complete_date || sprint.end_date)
  end

  def points_closed
    closed_issues.reduce(0){ |sum, issue| sum + (issue.estimation || sprint.issue_estimation_nil_value) }
  end

  def points_released
    released_issues.reduce(0){ |sum, issue| sum + (issue.estimation || sprint.issue_estimation_nil_value) }
  end

  def points_open
    open_issues.reduce(0){ |sum, issue| sum + (issue.estimation || sprint.issue_estimation_nil_value) }
  end

  def points_total
    issues.reduce(0){ |sum, issue| sum + (issue.estimation || sprint.issue_estimation_nil_value) }
  end

  def points_rejected
    rejected_issues.reduce(0){ |sum, issue| sum + (issue.estimation || sprint.issue_estimation_nil_value) }
  end

  def wbso_points_closed
    wbso_issues.reduce(0) do |sum, issue|
      if closed_in_sprint?(issue)
        sum += issue.estimation || sprint.issue_estimation_nil_value
      end
      sum
    end
  end

  def wbso_percentage_of_points_closed_per_wbso_project
    issues_per_wbso_project.inject({}) do |memo, (wbso_project, issues)|
      total = issues.reduce(0) do |sum, issue|
        if closed_in_sprint?(issue)
          sum += issue.estimation || sprint.issue_estimation_nil_value
        end
        sum
      end
      memo[wbso_project] = total  / points_closed.to_f * 100 if points_closed > 0
      memo
    end
  end

  def average_cycle_time
    issues_with_cycle_time = done_issues.select(&:cycle_time)
    return nil if issues_with_cycle_time.size == 0

    total_cycle_time = issues_with_cycle_time.reduce(0){ |memo, issue| memo += issue.cycle_time }
    total_cycle_time / issues_with_cycle_time.size
  end
end
