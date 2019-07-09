class DeploymentReportController < ApplicationController
  def overview
    @report = DeploymentReportService.new(DateTime.new(2019,1.1), DateTime.now).deployment_report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@report[:issues_table]), filename: "deployment_project_report.csv" }
      format.json { send_data @report.to_json }
    end
  end
end