class ReportController < ApplicationController
  def portfolio
    @dates = set_dates.reverse
    @selected_date = params[:date]&.to_datetime || @dates.last
    @department = Repository.for(:department).find(params[:department_id].to_i)

    @table = PortfolioReportService.for(@department.scrum_teams, @selected_date)

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@table), filename: "portfolio_report_week_#{@selected_date.cweek}_#{@selected_date.cweek + 1}.csv" }
    end
  end

  def cycle_time
    @board = Repository.for(:board).find(params[:board_id])
    @table = CycleTimeReportService.cycle_time_for_board(@board)

    stats = {
      table: @table,
      regression: CycleTimeReportService.linear_regression_for_board(@board),
      moving_averages: CycleTimeReportService.moving_averages_for_board(@board)
    }

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@table), filename: "cycle_time_report_team_#{@board.team.name}.csv" }
      format.json { send_data stats.to_json }
    end
  end

  def short_cycle_time
    @board = Repository.for(:board).find(params[:board_id])
    @table = CycleTimeReportService.short_cycle_time_for_board(@board)

    stats = {
      table: @table,
      regression: CycleTimeReportService.linear_regression_for_board(@board, :ready_for_prod_date),
      moving_averages: CycleTimeReportService.moving_averages_for_board(@board, :ready_for_prod_date)
    }

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@table), filename: "short_cycle_time_report_team_#{@board.team.name}.csv" }
      format.json { send_data stats.to_json }
    end
  end

  def deployment
    @deployment_project = Repository.for(:project).find(params[:deployment_project_key])
    @table = DeploymentReportService.for_project(@deployment_project)

    stats = {
      table: @table,
      regression: DeploymentReportService.linear_regression_for_project(@deployment_project),
    }

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@table), filename: "deployment_project_report_#{@deployment_project.key}.csv" }
      format.json { send_data stats.to_json }
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
