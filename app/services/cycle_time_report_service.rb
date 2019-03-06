class CycleTimeReportService
  def self.for_board(board)
    table = []
    header = ["Key", "In progress date", "Done date", "Cycle time (days)"]
    table << header

    board.cycle_times.each do |row|
      table << [row[0], row[1].strftime('%Y-%m-%d'), row[2].strftime('%Y-%m-%d'), row[3].round(1)]
    end

    table
  end
end
