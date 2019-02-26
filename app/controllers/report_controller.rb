class ReportController < ApplicationController

  def portfolio
    @table = PortfolioReportService.new.last_closed_sprint
    @report_type = "Portfolio"
    @dates = set_dates.reverse
  end

  private
  def set_dates
    week_number = DateTime.now.strftime('%W').to_i
    week_number = week_number - 1 if week_number % 2 != 0

    begin_date = DateTime.commercial(DateTime.now.year, week_number)
    dates = []
    5.times { |count| dates << (begin_date - (count * 2).weeks) }
    dates
  end
end
