class CycleTimeReportService
  def self.cycle_time_for(board)
    table = []
    header = ["Key", "In progress date", "Ready for prod date", "Done date", "Cycle time (days)", "Short cycle time (days)", "Delta"]
    table << header

    board.issues_with_cycle_time.reverse.each do |issue|
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

  def self.cycle_time_linear_regression(board)
    return [] if board.issues_with_cycle_time.size <= 2

    data = board.issues_with_cycle_time.map do |issue|
      { date: issue.done_date.to_time.to_i, cycle_time: issue.cycle_time }
    end
    model = Eps::Regressor.new(data, target: :cycle_time)

    [prediction(model, board.issues_with_cycle_time.first.done_date),
      prediction(model, board.issues_with_cycle_time.last.done_date)]
  end

  def self.short_cycle_time_linear_regression(board)
    return [] if board.issues_with_short_cycle_time.size <= 2

    data = board.issues_with_short_cycle_time.map do |issue|
      { date: issue.ready_for_prod_date.to_time.to_i, cycle_time: issue.short_cycle_time }
    end
    model = Eps::Regressor.new(data, target: :cycle_time)

    [prediction(model, board.issues_with_short_cycle_time.first.ready_for_prod_date),
      prediction(model, board.issues_with_short_cycle_time.last.ready_for_prod_date)]
  end

  def self.cycle_time_moving_averages(board)
    return [] if board.issues_with_cycle_time.size <= 2

    date =  board.issues_with_cycle_time.first.done_date
    end_date = board.issues_with_cycle_time.last.done_date
    moving_averages = []

    loop do
      moving_averages << [date.strftime('%Y-%m-%d'), board.cycle_time_moving_average_on(date)]

      date = date + 1.week
      if date >= end_date
        moving_averages << [end_date.strftime('%Y-%m-%d'), board.cycle_time_moving_average_on(end_date)]
        break
      end
    end

    moving_averages
  end

  def self.short_cycle_time_moving_averages(board)
    return [] if board.issues_with_short_cycle_time.size <= 2

    date =  board.issues_with_cycle_time.first.done_date
    end_date = board.issues_with_cycle_time.last.done_date
    moving_averages = []

    loop do
      moving_averages << [date.strftime('%Y-%m-%d'), board.short_cycle_time_moving_average_on(date)]

      date = date + 1.week
      if date >= end_date
        moving_averages << [end_date.strftime('%Y-%m-%d'), board.short_cycle_time_moving_average_on(end_date)]
        break
      end
    end

    moving_averages
  end

  private
  def self.prediction(model, date)
    [date.strftime('%Y-%m-%d'), model.predict(date: date.to_time.to_i)]
  end
end
