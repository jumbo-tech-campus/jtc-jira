class P1ReportController < ApplicationController
  def overview
    @report = P1ReportService.new(DateTime.new(2019,1.1), DateTime.now).p1_report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@report[:closed_issues_table]), filename: "closed_p1_issues.csv" }
      format.json { send_data @report.to_json }
    end
  end
end
