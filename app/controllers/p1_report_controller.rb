class P1ReportController < ApplicationController
  before_action :set_year_dates

  def overview
    @report = P1ReportService.new(@start_date, @end_date).p1_report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@report[:closed_issues_table]), filename: 'closed_p1_issues.csv' }
      format.json { send_data @report.to_json }
    end
  end
end
