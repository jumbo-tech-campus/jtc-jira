class DeploymentReportService
  def deployment_report
    {
      issues_table: issues_table,
      issue_count_per_day: issue_count_per_day.to_a,
      trend_count_per_week: linear_regression_for_issue_count
    }
  end

  def issues_table
    table = []
    header = ["Key", "Date", "Title"]
    table << header
    issues.reverse.each do |issue|
      table << [
        issue.key,
        issue.created.strftime('%Y-%m-%d'),
        issue.summary
      ]
    end

    table
  end

  def issues
    @p1_issues ||= retrieve_deployment_issues
  end

  def linear_regression_for_issue_count
    data = issue_count_per_day.map do |key, value|
      { date: Time.parse(key).to_i, deployments: value }
    end
    model = Eps::Regressor.new(data, target: :deployments)

    [prediction(model, issues.first.created), prediction(model, issues.last.created)]
  end

  def issue_count_per_day
    issues.inject({}) do |memo, issue|
      date = issue.created.strftime('%Y-%m-%d')
      if memo[date]
        memo[date] += 1
      else
        memo[date] = 1
      end
      memo
    end
  end

  private
  def prediction(model, date)
    [date.strftime('%Y-%m-%d'), model.predict(date: date.to_time.to_i)]
  end

  def retrieve_deployment_issues
    ConfigService.register_repositories
    JiraService.register_repositories

    issues = Repository.for(:issue_collection).find(2).sorted_issues

    CacheService.register_repositories
    issues
  end
end
