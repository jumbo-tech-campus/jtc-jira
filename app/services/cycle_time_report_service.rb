class CycleTimeReportService
  def self.for_board(board)
    table = []
    header = ["Key", "In progress date", "Done date", "Cycle time (days)"]
    table << header

    board.cycle_times.each do |row|
      table << [row[0], row[1].strftime('%Y-%m-%d'), row[2].strftime('%Y-%m-%d'), row[3].round(2)]
    end

    table
  end

  def self.linear_regression_for_board(board)
    data = board.cycle_times.map do |row|
      { date: row[2].to_time.to_i, cycle_time: row[3] }
    end
    model = Eps::Regressor.new(data, target: :cycle_time)
    puts model.summary

    [prediction(model, board.cycle_times.first[2]), prediction(model, board.cycle_times.last[2])]
  end

  private
  def self.prediction(model, date)
    [date.strftime('%Y-%m-%d'), model.predict(date: date.to_time.to_i)]
  end
end
