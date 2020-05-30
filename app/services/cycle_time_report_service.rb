class CycleTimeReportService
  def initialize(teams, start_date, end_date)
    @teams, @start_date, @end_date = teams, start_date, end_date
  end

  def cycle_time_report
    {
      table: cycle_time,
      cycle_trendline: cycle_time_linear_regression,
      cycle_averages: cycle_time_moving_averages,
      cycle_delta_trendline: cycle_time_delta_linear_regression,
      cycle_delta_averages: cycle_time_delta_moving_averages,
      short_cycle_trendline: short_cycle_time_linear_regression,
      short_cycle_averages: short_cycle_time_moving_averages
    }
  end

  def calculate_kpi_result
    sum = cycle_issues.map(&:cycle_time).inject(:+)
    average = sum / cycle_issues.size.to_f if sum

    results = CycleTimeOverviewReportService.new(@teams, @start_date, @end_date, 2.weeks).periodic_overall_results
    KpiResult.new(average, results)
  end

  def cycle_issues
    @teams.inject([]) do |memo, team|
      team_issues = team.issues_with_cycle_time.select do |issue|
        issue.release_date.between?(@start_date, @end_date) && team.is_active?(issue.release_date)
      end
      memo.concat(team_issues)
      memo
    end
  end

  def short_cycle_issues
    @teams.inject([]) do |memo, team|
      team_issues = team.issues_with_short_cycle_time.select do |issue|
        issue.pending_release_date.between?(@start_date, @end_date) && team.is_active?(issue.pending_release_date)
      end
      memo.concat(team_issues)
      memo
    end
  end

  def cycle_delta_issues
    @teams.inject([]) do |memo, team|
      team_issues = team.issues_with_cycle_time_delta.select do |issue|
        issue.release_date.between?(@start_date, @end_date) && team.is_active?(issue.release_date)
      end
      memo.concat(team_issues)
      memo
    end
  end

  def issues
    cycle_issues | short_cycle_issues
  end

  def cycle_time
    table = []
    header = ["Key", "In progress date", "Pending release date", "Release date",
      "Cycle time (days)", "Short cycle time (days)", "Delta", "Resolution"]
    table << header

    sorted_issues = issues.sort do |a, b|
      if a.cycle_time.nil? || b.cycle_time.nil?
        1
      else
        a.cycle_time <=> b.cycle_time
      end
    end

    sorted_issues.reverse.each do |issue|
      table << [
        issue.key,
        issue.in_progress_date.strftime('%Y-%m-%d'),
        issue.pending_release_date&.strftime('%Y-%m-%d'),
        issue.release_date&.strftime('%Y-%m-%d'),
        issue.cycle_time&.round(2),
        issue.short_cycle_time&.round(2),
        issue.cycle_time_delta&.round(2),
        issue.resolution
      ]
    end

    table
  end

  def cycle_time_linear_regression
    return [] if cycle_issues.size <= 2

    data = cycle_issues.map do |issue|
      { date: issue.release_date.to_time.to_i, cycle_time: issue.cycle_time }
    end
    model = Eps::Model.new(data, target: :cycle_time, algorithm: :linear_regression)

    [prediction(model, @start_date), prediction(model, @end_date)]
  end

  def short_cycle_time_linear_regression
    return [] if short_cycle_issues.size <= 2

    data = short_cycle_issues.map do |issue|
      { date: issue.pending_release_date.to_time.to_i, short_cycle_time: issue.short_cycle_time }
    end
    model = Eps::Model.new(data, target: :short_cycle_time, algorithm: :linear_regression)

    [prediction(model, @start_date), prediction(model, @end_date)]
  end


  def cycle_time_delta_linear_regression
    return [] if cycle_delta_issues.size <= 2

    data = cycle_delta_issues.map do |issue|
      { date: issue.release_date.to_time.to_i, cycle_time_delta: issue.cycle_time_delta }
    end
    model = Eps::Model.new(data, target: :cycle_time_delta, algorithm: :linear_regression)

    [prediction(model, @start_date), prediction(model, @end_date)]
  end

  def cycle_time_moving_averages
    return [] if cycle_issues.size <= 2

    date =  @start_date
    moving_averages = []

    loop do
      moving_averages << [date.strftime('%Y-%m-%d'), cycle_time_moving_average_on(date)]

      date = date + 1.week
      if date >= @end_date
        moving_averages << [@end_date.strftime('%Y-%m-%d'), cycle_time_moving_average_on(@end_date)]
        break
      end
    end

    moving_averages
  end

  def short_cycle_time_moving_averages
    return [] if short_cycle_issues.size <= 2

    date =  @start_date
    moving_averages = []

    loop do
      moving_averages << [date.strftime('%Y-%m-%d'), short_cycle_time_moving_average_on(date)]

      date = date + 1.week
      if date >= @end_date
        moving_averages << [@end_date.strftime('%Y-%m-%d'), short_cycle_time_moving_average_on(@end_date)]
        break
      end
    end

    moving_averages
  end

  def cycle_time_delta_moving_averages
    return [] if cycle_delta_issues.size <= 2

    date = @start_date
    moving_averages = []

    loop do
      moving_averages << [date.strftime('%Y-%m-%d'), cycle_time_delta_moving_average_on(date)]

      date = date + 1.week
      if date >= @end_date
        moving_averages << [@end_date.strftime('%Y-%m-%d'), cycle_time_delta_moving_average_on(@end_date)]
        break
      end
    end

    moving_averages
  end

  def cycle_time_moving_average_on(date, period = 2.weeks)
    cycle_time_array = cycle_issues.inject([]) do |memo, issue|
      memo << issue.cycle_time if issue.release_date.between?(date.end_of_day - period, date.end_of_day)
      memo
    end

    if cycle_time_array.size > 0
      cycle_time_array.inject(:+) / cycle_time_array.size.to_f
    else
      0
    end
  end

  def short_cycle_time_moving_average_on(date, period = 2.weeks)
    cycle_time_array = short_cycle_issues.inject([]) do |memo, issue|
      memo << issue.short_cycle_time if issue.pending_release_date.between?(date.end_of_day - period, date.end_of_day)
      memo
    end

    if cycle_time_array.size > 0
      cycle_time_array.inject(:+) / cycle_time_array.size.to_f
    else
      0
    end
  end

  def cycle_time_delta_moving_average_on(date, period = 2.weeks)
    cycle_time_array = cycle_delta_issues.inject([]) do |memo, issue|
      memo << issue.cycle_time_delta if issue.release_date.between?(date.end_of_day - period, date.end_of_day)
      memo
    end

    if cycle_time_array.size > 0
      cycle_time_array.inject(:+) / cycle_time_array.size.to_f
    else
      0
    end
  end

  private
  def prediction(model, date)
    [date.strftime('%Y-%m-%d'), model.predict(date: date.to_time.to_i)]
  end
end
