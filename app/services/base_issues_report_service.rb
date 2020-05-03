class BaseIssuesReportService
  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def issue_count_property
    :created
  end

  def overview
    {
      issue_count_per_day: cumulative_count_per_day,
      count: issues.size
    }
  end

  def calculate_kpi_result
    KpiResult.new(cumulative_count_per_day.last[1], cumulative_count_per_day)
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
    @issues ||= retrieve_issues
  end

  def closed_issues
    issues.select{ |issue| issue.closed? }
  end

  def open_issues
    issues.select{ |issue| !issue.closed? }
  end

  def issue_count_per_week(issue_collection = nil)
    issues_to_count = issue_collection || issues
    date = @start_date
    count_per_week = {}

    loop do
      break if date > @end_date

      count_per_week[date.cweek] = 0
      date = date + 1.week
    end

    issues_to_count.inject(count_per_week) do |memo, issue|
      memo[issue.send(issue_count_property).cweek] += 1
      memo
    end
  end

  def issue_count_per_day(issue_collection = nil)
    issues_to_count = issue_collection || issues
    date = @start_date
    count_per_day = {}

    loop do
      break if date > @end_date

      count_per_day[date.strftime('%Y-%m-%d')] = 0
      date = date + 1.day
    end

    issues_to_count.inject(count_per_day) do |memo, issue|
      date = issue.send(issue_count_property).strftime('%Y-%m-%d')
      memo[date] += 1
      memo
    end
  end

  def cumulative_count_per_day(issue_collection = nil)
    accumulator = 0
    issue_count_per_day(issue_collection).map do |day, count|
      accumulator += count
      [day, accumulator]
    end
  end

  def linear_regression_for_issue_count
    data = issue_count_per_day.map do |key, value|
      { date: Time.parse(key).to_i, value: value }
    end
    model = Eps::Model.new(data, target: :value, algorithm: :linear_regression)

    [predict_on_date(model, @start_date), predict_on_date(model, @end_date)]
  end

  protected
  def retrieve_issues
  end

  def predict_on_date(model, date)
    [date.strftime('%Y-%m-%d'), model.predict(date: date.to_time.to_i)]
  end
end
