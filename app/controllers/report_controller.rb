class ReportController < ApplicationController
  def portfolio
    set_dates
    @selected_date = params[:date]&.to_datetime || @dates.last
    department_id = params[:department_id] || '1'
    @department = Repository.for(:department).find(department_id.to_i)

    @table = PortfolioReportService.for(@department.scrum_teams, @selected_date)

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@table), filename: "portfolio_report_week_#{@selected_date.cweek}_#{@selected_date.cweek + 1}.csv" }
    end
  end

  def cycle_time
    @end_date = ApplicationHelper.safe_parse(params[:end_date]) || Date.today
    @start_date = ApplicationHelper.safe_parse(params[:start_date]) || Date.today - 2.months

    unless params[:board_id]
      cycle_time_deployment_constraint
      return
    end

    @board = Repository.for(:board).find(params[:board_id])
    @report = CycleTimeReportService.new([@board], @start_date, @end_date).cycle_time_report
    @table = @report[:table]

    respond_to do |format|
      format.html { render :cycle_time_team }
      format.csv { send_data to_csv(@table), filename: "cycle_time_report_team_#{@board.team.name}.csv" }
      format.json { send_data @report.to_json }
    end
  end

  def cycle_time_deployment_constraint
    deployment_constraint_id = params[:deployment_constraint_id] || '1'
    @deployment_constraint = Repository.for(:deployment_constraint).find(deployment_constraint_id.to_i)
    @deployment_constraints = Repository.for(:deployment_constraint).all.sort_by(&:name)
    boards = @deployment_constraint.teams.map(&:board)

    @report = CycleTimeReportService.new(boards, @start_date, @end_date).cycle_time_report

    respond_to do |format|
      format.html { render :cycle_time_deployment_constraint }
      format.csv { send_data to_csv(@report[:table]), filename: "cycle_time_report_constraint_#{@deployment_constraint.name}.csv" }
      format.json { send_data @report.to_json }
    end
  end

  def deployment
    @report = DeploymentReportService.new.deployment_report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@report[:issues_table]), filename: "deployment_project_report.csv" }
      format.json { send_data @report.to_json }
    end
  end

  def p1
    @report = P1ReportService.new.p1_report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@report[:closed_issues_table]), filename: "closed_p1_issues.csv" }
      format.json { send_data @report.to_json }
    end
  end

  private
  def set_dates
    date = DateTime.new(2019, 1, 4)
    @dates = [date]

    loop do
      date = date + 2.weeks
      break if date > DateTime.now

      @dates << date
    end
  end

  def to_csv(table)
    ::CSV.generate(headers: true) do |csv|
      table.each do |row|
        csv << row
      end
    end
  end
end
