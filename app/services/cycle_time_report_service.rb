class CycleTimeReportService
  def self.cycle_time_for_board(board)
    table = []
    header = ["Key", "In progress date", "Done date", "Cycle time (days)"]
    table << header

    board.cycle_times.reverse.each do |row|
      table << [row[0], row[1].strftime('%Y-%m-%d'), row[2].strftime('%Y-%m-%d'), row[3].round(2)]
    end

    table
  end

  def self.short_cycle_time_for_board(board)
    table = []
    header = ["Key", "In progress date", "Ready for prod date", "Short cycle time (days)"]
    table << header

    board.cycle_times(:ready_for_prod_date).reverse.each do |row|
      table << [row[0], row[1].strftime('%Y-%m-%d'), row[2].strftime('%Y-%m-%d'), row[3].round(2)]
    end

    table
  end

  def self.linear_regression_for_board(board, done_type = :done_date)
    cycle_times = board.cycle_times(done_type)
    return [] if cycle_times.size <= 2

    data = cycle_times.map do |row|
      { date: row[2].to_time.to_i, cycle_time: row[3] }
    end
    model = Eps::Regressor.new(data, target: :cycle_time)

    [prediction(model, cycle_times.first[2]), prediction(model, cycle_times.last[2])]
  end

  def self.moving_averages_for_board(board, done_type = :done_date)
    cycle_times = board.cycle_times(done_type)
    return [] if cycle_times.size <= 2

    date =  cycle_times.first[2]
    end_date = cycle_times.last[2]
    moving_averages = []

    loop do
      moving_averages << [date.strftime('%Y-%m-%d'), board.cycle_time_moving_average_on(date, done_type)]

      date = date + 1.week
      if date >= end_date
        moving_averages << [end_date.strftime('%Y-%m-%d'), board.cycle_time_moving_average_on(end_date, done_type)]
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
