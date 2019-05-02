class P1ReportService
  def p1_report
    {
      closed_issues: table(closed_p1_issues),
      open_issues: table(open_p1_issues),
      issue_count_per_week: issue_count_per_week.to_a,
      trend_count_per_week: linear_regression_for_issue_count,
      trend_resolution_time: linear_regression_for_resolution_time
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

    [predict_count(model, 1), predict_count(model, p1_issues.last.created.cweek)]
  end

  def linear_regression_for_resolution_time
    return [] if closed_p1_issues.size <= 2

    data = closed_p1_issues.map do |issue|
      { date: issue.resolution_date.to_time.to_i, resolution_time: issue.resolution_time }
    end
    model = Eps::Regressor.new(data, target: :resolution_time)

    [predict_time(model, closed_p1_issues.first.resolution_date), predict_time(model, closed_p1_issues.last.resolution_date)]
  end

  def retrieve_p1_issues
    ConfigService.register_repositories
    JiraService.register_repositories

    issues = Repository.for(:issue_collection).find_by(name: 'P1 issues 2019').sorted_issues

    CacheService.register_repositories
    issues
  end

  private
  def predict_count(model, week)
    [week, model.predict(week: week)]
  end

  def predict_time(model, date)
    [date.strftime('%Y-%m-%d'), model.predict(date: date.to_time.to_i)]
  end
end
