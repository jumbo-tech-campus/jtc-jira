class P1ReportService < BaseIssuesReportService
  def p1_report
    {
      closed_issues_table: closed_issues_table,
      open_issues_table: open_issues_table,
      issue_count_per_week: issue_count_per_week.to_a,
      trend_count_per_week: linear_regression_for_issue_count,
      trend_time_to_recover: linear_regression_for_time_to_recover,
      time_to_recover_averages: time_to_recover_moving_averages,
      cumulative_count_per_cause_per_day: cumulative_count_per_cause_per_day,
      kpi_metrics: kpi_metrics
    }
  end

  def calculate_kpi_result(type)

    case type
    when :p1s
      KpiResult.new(cumulative_count_per_day.last[1], cumulative_count_per_day)
    when :time_to_recover
      KpiResult.new(average_time(:time_to_recover), average_time_per_period(:time_to_recover).map { |period, avg| [period.start_date.cweek, avg] })
    when :time_to_detect
      KpiResult.new(average_time(:time_to_detect), average_time_per_period(:time_to_detect).map { |period, avg| [period.start_date.cweek, avg] })
    when :change_fail
      KpiResult.new(change_fail_percentage, change_fail_percentage_per_period(1.week).map { |period, perc| [period.start_date.cweek, perc] })
    end
  end

  def issues_per_cause
    issues.each_with_object({}) do |issue, memo|
      issue.causes.each do |cause|
        if memo[cause]
          memo[cause] << issue
        else
          memo[cause] = [issue]
        end
      end
    end
  end

  def cumulative_count_per_cause_per_day
    result = issues_per_cause.map do |cause, issues|
      { cause: cause, issue_count: cumulative_count_per_day(issues).to_a }
    end

    result << { cause: 'All', issue_count: cumulative_count_per_day.to_a }
    result
  end

  def closed_issues_table
    table = []
    header = ['Key', 'Date', 'Title', 'Cause', 'Time to detect', 'Time to repair', 'Time to recover']
    table << header
    closed_issues.reverse.each do |issue|
      table << [
        issue.key,
        issue.created.strftime('%Y-%m-%d'),
        issue.summary,
        issue.causes.join(', '),
        ApplicationHelper.format_to_days_hours_and_minutes(issue.time_to_detect),
        ApplicationHelper.format_to_days_hours_and_minutes(issue.time_to_repair),
        ApplicationHelper.format_to_days_hours_and_minutes(issue.time_to_recover)
      ]
    end

    table
  end

  def open_issues_table
    table = []
    header = %w[Key Date Title Assignee]
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

  def kpi_metrics
    table = []
    closed_issues.reverse.each do |issue|
      table << [
        issue.created.strftime('%Y-%m-%d'),
        issue.time_to_detect,
        issue.time_to_repair,
        issue.time_to_recover ? issue.time_to_recover * 24 : nil
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

  def linear_regression_for_time_to_recover
    return [] if incidents_with_end_date.size <= 2

    data = incidents_with_end_date.select.map do |issue|
      { date: issue.end_date.to_time.to_i, time_to_recover: issue.time_to_recover }
    end
    model = Eps::Model.new(data, target: :time_to_recover, algorithm: :linear_regression)

    [predict_on_date(model, @start_date), predict_on_date(model, @end_date)]
  end

  def time_to_recover_moving_averages
    return [] if incidents_with_end_date.size <= 2

    date = @start_date
    moving_averages = []

    loop do
      moving_averages << [date.strftime('%Y-%m-%d'), time_to_recover_moving_average_on(date)]

      date += 1.week
      if date >= @end_date
        moving_averages << [@end_date.strftime('%Y-%m-%d'), time_to_recover_moving_average_on(@end_date)]
        break
      end
    end

    moving_averages
  end

  def time_to_recover_moving_average_on(date, period = 2.weeks)
    time_to_recover_array = incidents_with_end_date.each_with_object([]) do |issue, memo|
      memo << issue.time_to_recover if issue.end_date.between?(date.end_of_day - period, date.end_of_day)
    end

    if !time_to_recover_array.empty?
      time_to_recover_array.inject(:+) / time_to_recover_array.size.to_f
    else
      0
    end
  end

  def p1s_per_period(period_duration = 1.week)
    periods = Period.create_periods(@start_date, @end_date, period_duration)
    periods.each_with_object do |period, memo|
      memo[period] = incidents_with_end_date.select do |incident|
        incident.end_date.between?(period.start_date, period.end_date)
      end
    end
  end

  def average_time_per_period(metric)
    p1s_per_period.map do |period, incidents|
      if period.start_date > DateTime.now || incidents.empty?
        [period, nil]
      else
        [period, (incidents.sum(&metric) / incidents.size.to_f) * 24 * 60]
      end
    end
  end

  def average_time(metric)
    return nil if incidents_with_end_date.empty?

    (incidents_with_end_date.sum(&metric) / incidents_with_end_date.size.to_f) * 24 * 60
  end

  protected

  def retrieve_issues
    ish_live_date = DateTime.new(2019, 9, 29)
    ish_live_date = @start_date if ish_live_date < @start_date

    query = "(priority = 'P1 - Urgent' AND created <= #{(@end_date + 1.day).strftime('%Y-%m-%d')} AND issuetype = Incident AND reporter in (servicedesk.it, engin.keyif) AND created >= #{@start_date.strftime('%Y-%m-%d')}) OR (priority = 'P1 - Urgent' AND created <= #{(@end_date + 1.day).strftime('%Y-%m-%d')} AND project = UI AND created > #{ish_live_date.strftime('%Y-%m-%d')}) ORDER BY created ASC, key DESC"
    # use Jira repository because we want real time data
    ::Jira::IssueRepository.new(::Jira::JiraClient.new).find_by(query: query)
  end

  def incidents_with_end_date
    issues.select { |issue| issue.end_date.present? }
  end

  def predict_count(model, week)
    [week, model.predict(week: week)]
  end

  def deployment_report_service
    @deployment_report_service ||= DeploymentReportService.new(@start_date, @end_date)
  end

  def incidents_caused_by_deploys
    issues.select { |issue| issue.causes.include?('Deployment') }
  end

  def incidents_caused_by_deploys_per_period(period_duration = 1.week)
    periods = Period.create_periods(@start_date, @end_date, period_duration)
    periods.each_with_object({}) do |period, memo|
      memo[period] = incidents_caused_by_deploys.select do |incident|
        incident.created.between?(period.start_date, period.end_date)
      end
    end
  end

  def change_fail_percentage
    number_of_deploys = deployment_report_service.issues.size
    number_of_deployment_related_incidents = incidents_caused_by_deploys.size

    (number_of_deployment_related_incidents / number_of_deploys.to_f) * 100
  end

  def change_fail_percentage_per_period(period_duration = 1.week)
    deployment_report_service.issues_per_period(period_duration).map do |period, deploys|
      if period.start_date > DateTime.now || deploys.empty?
        [period, nil]
      else
        incidents = incidents_caused_by_deploys_per_period(period_duration).find do |p2, incidents|
          period == p2
        end
        [period, (incidents[1].size / deploys.size.to_f) * 100]
      end
    end
  end
end
