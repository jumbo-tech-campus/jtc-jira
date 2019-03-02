class ReportController < ApplicationController

  def portfolio
    @report_type = "Portfolio"
    @dates = set_dates.reverse
    @selected_date = params[:date]&.to_datetime || @dates.last
    @table = PortfolioReportService.for_sprints_on(@selected_date)

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@table), filename: "portfolio_report_week_#{@selected_date.cweek}_#{@selected_date.cweek + 1}.csv" }
    end
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

  def to_csv(table)
    ::CSV.generate(headers: true) do |csv|
      table.each do |row|
        csv << row
      end
    end
  end
end