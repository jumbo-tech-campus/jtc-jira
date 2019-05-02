class P1ReportService
  def p1_report
    {
      closed_issues: table(closed_p1_issues),
      open_issues: table(open_p1_issues),
      issue_count_per_week: issue_count_per_week.to_a,
      trend_count_per_week: linear_regression_for_issue_count
    }
  end

  def p1_issues
    @p1_issues ||= retrieve_p1_issues
  end

  def open_p1_issues
    p1_issues.select{ |issue| !issue.closed? }
  end

  def closed_p1_issues
    p1_issues.select{ |issue| issue.closed? }
  end

  def table(issues)
    table = []
    header = ["Key", "Date", "Title", "Resolution time (days)"]
    table << header
    issues.reverse.each do |issue|
      table << [
        issue.key,
        issue.created.strftime('%Y-%m-%d'),
        issue.summary,
        issue.resolution_time&.round(2)
      ]
    end

    table
  end

  def issue_count_per_week
    p1_issues.inject({}) do |memo, issue|
      week = issue.created.cweek
      if memo[week]
        memo[week] += 1
      else
        memo[week] = 1
      end
      memo
    end
  end

  def linear_regression_for_issue_count
    data = issue_count_per_week.map do |key, value|
      { week: key, issue_count: value }
    end
    model = Eps::Regressor.new(data, target: :issue_count)

    [prediction(model, 1), prediction(model, p1_issues.last.created.cweek)]
  end

  def retrieve_p1_issues
    ConfigService.register_repositories
    JiraService.register_repositories

    issues = Repository.for(:issue_collection).find_by(name: 'P1 issues 2019').sorted_issues

    CacheService.register_repositories
    issues
  end

  private
  def prediction(model, week)
    [week, model.predict(week: week)]
  end
end
