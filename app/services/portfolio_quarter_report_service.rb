class PortfolioQuarterReportService
  def initialize(quarter)
    @quarter = quarter
    @boards = Repository.for(:team).all.map(&:board)
    @parent_epics = ParentEpicService.new(quarter.fix_version).parent_epics
  end

  def quarter_report
    {
      table: table,
      unplanned_table: unplanned_table
    }
  end

  private
  def issues
    return @issues if @issues

    @issues = @boards.inject([]) do |memo, board|
      board_issues = board.issues.select do |issue|
        issue.done_date && issue.done_date.year == @quarter.year &&
          issue.done_date.cweek >= @quarter.start_week &&
          issue.done_date.cweek <= @quarter.end_week
      end
      memo.concat(board_issues)
      memo
    end
  end

  def issues_per_portfolio_epic
    @issues_per_portfolio_epic ||= issues.inject({}) do |memo, issue|
      if issue.parent_epic
        key = issue.parent_epic.key
      else
        key = "DEV"
      end

      if memo[key]
        memo[key] << issue unless memo[key].include?(issue)
      else
        memo[key] = [issue]
      end
      memo
    end
  end

  def unplanned_issues_per_portfolio_epic
    portfolio_epic_keys = @parent_epics.map(&:key)

    issues_per_portfolio_epic.inject({}) do |memo, element|
      memo[element[0]] = element[1] unless portfolio_epic_keys.include?(element[0])
      memo
    end
  end

  def planned_issues_per_portfolio_epic
    portfolio_epic_keys = @parent_epics.map(&:key)

    issues_per_portfolio_epic.inject({}) do |memo, element|
      memo[element[0]] = element[1] if portfolio_epic_keys.include?(element[0])
      memo
    end
  end

  def table
    table = []
    header = ["Assignee", "Key", "Title", "Plan", "Issues closed", "Points closed"]
    table << header
    @parent_epics.each do |parent_epic|
      table << [
        parent_epic.assignee,
        parent_epic.key,
        parent_epic.summary,
        parent_epic.fix_version,
        planned_issues_per_portfolio_epic[parent_epic.key]&.size,
        planned_issues_per_portfolio_epic[parent_epic.key]&.sum(&:estimation)
      ]
      parent_epic.epics.each do |epic|
        issues_for_epic = planned_issues_per_portfolio_epic[parent_epic.key].select do |issue|
          issue.epic == epic
        end if planned_issues_per_portfolio_epic[parent_epic.key]

        table << [
          nil,
          epic.key,
          epic.name,
          parent_epic.fix_version,
          issues_for_epic&.size,
          issues_for_epic&.sum(&:estimation)
        ]
      end
    end

    unplanned_issues_per_portfolio_epic.each do |key, issues|
      next if key == "DEV"

      parent_epic = issues.first.parent_epic

      table << [
        parent_epic.assignee,
        parent_epic.key,
        parent_epic.summary,
        parent_epic.fix_version,
        issues.size,
        issues.sum(&:estimation)
      ]

      issues_per_epic = issues.inject({}) do |memo, issue|
        key = issue.epic.key
        if memo[key]
          memo[key] << issue
        else
          memo[key] = [issue]
        end
        memo
      end

      issues_per_epic.each do |key, epic_issues|
        table << [
          nil,
          key,
          epic_issues.first.epic.name,
          epic_issues.first.parent_epic.fix_version,
          epic_issues.size,
          epic_issues.sum(&:estimation)
        ]
      end
    end

    table
  end

  def unplanned_table
    table = []
    header = ["Key", "Title", "Issues closed", "Points closed"]
    table << header

    return table unless issues_per_portfolio_epic['DEV']

    issues_per_epic = issues_per_portfolio_epic['DEV'].inject({}) do |memo, issue|
      key = issue.epic&.key || "DEV"
      if memo[key]
        memo[key] << issue
      else
        memo[key] = [issue]
      end
      memo
    end

    issues_per_epic.each do |key, epic_issues|
      table << [
        key,
        epic_issues.first.epic&.name || "Issues not assigned to an epic",
        epic_issues.size,
        epic_issues.sum(&:estimation)
      ]
    end

    table
  end
end