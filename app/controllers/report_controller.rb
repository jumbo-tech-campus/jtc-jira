class ReportController < ApplicationController

  def portfolio
    @report_type = "Portfolio"
    @dates = set_dates.reverse
    @selected_date = params[:date].to_datetime || @dates.last
    @table = PortfolioReportService.for_sprints_on(@selected_date)
  end

  private
  def set_dates
    week_number = DateTime.now.strftime('%W').to_i
    week_number = week_number - 1 if week_number % 2 == 0
    # always select a Friday, no sprints ever start on Friday at JTC
    begin_date = DateTime.commercial(DateTime.now.year, week_number) + 4.days
    dates = []
    5.times { |count| dates << (begin_date - (count * 2).weeks) }
    dates
  end
end
