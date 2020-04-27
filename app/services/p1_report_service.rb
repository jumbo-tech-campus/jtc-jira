class P1ReportService < BaseIssuesReportService
  def p1_report
    {
      closed_issues_table: closed_issues_table,
      open_issues_table: open_issues_table,
      issue_count_per_week: issue_count_per_week.to_a,
      trend_count_per_week: linear_regression_for_issue_count,
      trend_resolution_time: linear_regression_for_resolution_time,
      resolution_averages: resolution_time_moving_averages,
      cumulative_count_per_label_per_day: cumulative_count_per_label_per_day,
    }
  end

  def issues_per_label
    issues.inject({}) do |memo, issue|
      issue.labels.each do |label|
        if memo[label]
          memo[label] << issue
        else
          memo[label] = [issue]
        end
      end
      memo
    end
  end

  def cumulative_count_per_label_per_day
    result = issues_per_label.map do |label, issues|
      { label: label, issue_count: cumulative_count_per_day(issues).to_a }
    end

    result << { label: 'All', issue_count: cumulative_count_per_day.to_a }
    result
  end

  def closed_issues_table
    table = []
    header = ["Key", "Date", "Title", "Labels", "Resolution time (days)"]
    table << header
    closed_issues.reverse.each do |issue|
      table << [
        issue.key,
        issue.created.strftime('%Y-%m-%d'),
        issue.summary,
        issue.labels.join(', '),
        issue.resolution_time&.round(2)
      ]
    end

    table
  end

  def open_issues_table
    table = []
    header = ["Key", "Date", "Title", "Assignee"]
    table << header
    open_issues.reverse.each do |issue|
      table << [
        issue.key,
        issue.created.strftime('%Y-%m-%d'),
        issue.summary,
        issue.assignee
      ]
    end

    table
  end

  def linear_regression_for_issue_count
    data = issue_count_per_week.map do |key, value|
      { week: key, issue_count: value }
    end
    model = Eps::Model.new(data, target: :issue_count, algorithm: :linear_regression)

    # NOTE: sometimes the last days of the year are in week 1 of the next year
    # using %W will always report week 52 in that case
    # however, it will also report week 0 if you use it for start_date
    [predict_count(model, @start_date.cweek), predict_count(model, @end_date.strftime('%W').to_i)]
  end

  def linear_regression_for_resolution_time
    return [] if closed_issues.size <= 2

    data = closed_issues.map do |issue|
      { date: issue.resolution_date.to_time.to_i, resolution_time: issue.resolution_time }
    end
    model = Eps::Model.new(data, target: :resolution_time, algorithm: :linear_regression)

    [predict_on_date(model, @start_date), predict_on_date(model, @end_date)]
  end

  def resolution_time_moving_averages
    return [] if closed_issues.size <= 2

    date =  @start_date
    moving_averages = []

    loop do
      moving_averages << [date.strftime('%Y-%m-%d'), resolution_time_moving_average_on(date)]

      date = date + 1.week
      if date >= @end_date
        moving_averages << [@end_date.strftime('%Y-%m-%d'), resolution_time_moving_average_on(@end_date)]
        break
      end
    end

    moving_averages
  end

  def resolution_time_moving_average_on(date, period = 2.weeks)
    resolution_time_array = closed_issues.inject([]) do |memo, issue|
      memo << issue.resolution_time if issue.created.between?(date.end_of_day - period, date.end_of_day)
      memo
    end

    if resolution_time_array.size > 0
      resolution_time_array.inject(:+) / resolution_time_array.size.to_f
    else
      0
    end
  end

  protected
  def retrieve_issues
    ish_live_date = DateTime.new(2019,9,29)
    ish_live_date = @start_date if ish_live_date < @start_date

    query = "(priority = 'P1 - Urgent' AND created <= #{@end_date.strftime('%Y-%m-%d')} AND issuetype = Incident AND reporter in (servicedesk.it, engin.keyif) AND created > #{@start_date.strftime('%Y-%m-%d')}) OR (priority = 'P1 - Urgent' AND created <= #{@end_date.strftime('%Y-%m-%d')} AND project = UI AND created > #{ish_live_date.strftime('%Y-%m-%d')}) ORDER BY created ASC, key DESC"
    # use Jira repository because we want real time data
    ::Jira::IssueRepository.new(::Jira::JiraClient.new).find_by(query: query)
  end

  def predict_count(model, week)
    [week, model.predict(week: week)]
  end
end
