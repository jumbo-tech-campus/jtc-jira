class CycleTimeReportService
  def initialize(board, start_date, end_date)
    @board, @start_date, @end_date = board, start_date, end_date
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

  def issues
    @board.issues_with_cycle_time.select do |issue|
      issue.done_date && issue.done_date.between?(@start_date, @end_date)
    end
  end

  def short_cycle_issues
    @board.issues_with_short_cycle_time.select do |issue|
      issue.ready_for_prod_date && issue.ready_for_prod_date.between?(@start_date, @end_date)
    end
  end

  def cycle_delta_issues
    @board.issues_with_cycle_time_delta.select do |issue|
      issue.done_date && issue.done_date.between?(@start_date, @end_date)
    end
  end

  def cycle_time
    table = []
    header = ["Key", "In progress date", "Ready for prod date", "Done date", "Cycle time (days)", "Short cycle time (days)", "Delta"]
    table << header

    issues.reverse.each do |issue|
      table << [
        issue.key,
        issue.in_progress_date.strftime('%Y-%m-%d'),
        issue.ready_for_prod_date&.strftime('%Y-%m-%d'),
        issue.done_date.strftime('%Y-%m-%d'),
        issue.cycle_time.round(2),
        issue.short_cycle_time&.round(2),
        issue.cycle_time_delta&.round(2)
      ]
    end

    table
  end

  def cycle_time_linear_regression
    return [] if issues.size <= 2

    data = issues.map do |issue|
      { date: issue.done_date.to_time.to_i, cycle_time: issue.cycle_time }
    end
    model = Eps::Regressor.new(data, target: :cycle_time)

    [prediction(model, issues.first.done_date),
      prediction(model, issues.last.done_date)]
  end

  def short_cycle_time_linear_regression
    return [] if short_cycle_issues.size <= 2

    data = short_cycle_issues.map do |issue|
      { date: issue.ready_for_prod_date.to_time.to_i, short_cycle_time: issue.short_cycle_time }
    end
    model = Eps::Regressor.new(data, target: :short_cycle_time)

    [prediction(model, short_cycle_issues.first.ready_for_prod_date),
      prediction(model, short_cycle_issues.last.ready_for_prod_date)]
  end


  def cycle_time_delta_linear_regression
    return [] if cycle_delta_issues.size <= 2

    data = cycle_delta_issues.map do |issue|
      { date: issue.done_date.to_time.to_i, cycle_time_delta: issue.cycle_time_delta }
    end
    model = Eps::Regressor.new(data, target: :cycle_time_delta)

    [prediction(model, cycle_delta_issues.first.done_date),
      prediction(model, cycle_delta_issues.last.done_date)]
  end

  def cycle_time_moving_averages
    return [] if issues.size <= 2

    date =  issues.first.done_date
    end_date = issues.last.done_date
    moving_averages = []

    loop do
      moving_averages << [date.strftime('%Y-%m-%d'), @board.cycle_time_moving_average_on(date)]

      date = date + 1.week
      if date >= end_date
        moving_averages << [end_date.strftime('%Y-%m-%d'), @board.cycle_time_moving_average_on(end_date)]
        break
      end
    end

    moving_averages
  end

  def short_cycle_time_moving_averages
    return [] if short_cycle_issues.size <= 2

    date =  issues.first.done_date
    end_date = issues.last.done_date
    moving_averages = []

    loop do
      moving_averages << [date.strftime('%Y-%m-%d'), @board.short_cycle_time_moving_average_on(date)]

      date = date + 1.week
      if date >= end_date
        moving_averages << [end_date.strftime('%Y-%m-%d'), @board.short_cycle_time_moving_average_on(end_date)]
        break
      end
    end

    moving_averages
  end

  def cycle_time_delta_moving_averages
    return [] if cycle_delta_issues.size <= 2

    date =  cycle_delta_issues.first.done_date
    end_date = cycle_delta_issues.last.done_date
    moving_averages = []

    loop do
      moving_averages << [date.strftime('%Y-%m-%d'), @board.cycle_time_delta_moving_average_on(date)]

      date = date + 1.week
      if date >= end_date
        moving_averages << [end_date.strftime('%Y-%m-%d'), @board.cycle_time_delta_moving_average_on(end_date)]
        break
      end
    end

    moving_averages
  end

  private
  def prediction(model, date)
    [date.strftime('%Y-%m-%d'), model.predict(date: date.to_time.to_i)]
  end
end
