class CycleTimeReportController < ApplicationController
  before_action :set_dates
  before_action :set_deployment_constraint, only: [:two_week_overview, :four_week_overview, :deployment_constraint]
  before_action :set_department, only: [:two_week_overview, :four_week_overview]
  before_action :set_years, only: [:two_week_overview, :four_week_overview]

  def team
    @board = Repository.for(:board).find(params[:board_id])
    @report = CycleTimeReportService.new([@board], @start_date, @end_date).cycle_time_report
    @table = @report[:table]

    respond_to do |format|
      format.html { render :team }
      format.csv { send_data to_csv(@table), filename: "cycle_time_report_team_#{@board.team.name}.csv" }
      format.json { send_data @report.to_json }
    end
  end

  def deployment_constraint
    boards = @deployment_constraint.teams.map(&:board).compact

    @report = CycleTimeReportService.new(boards, @start_date, @end_date).cycle_time_report

    respond_to do |format|
      format.html { render :deployment_constraint }
      format.csv { send_data to_csv(@report[:table]), filename: "cycle_time_report_constraint_#{@deployment_constraint.name}.csv" }
      format.json { send_data @report.to_json }
    end
  end

  def two_week_overview
    boards = teams.map(&:board).compact
    @report = CycleTimeOverviewReportService.new(boards, DateTime.new(@year, 1, 1), DateTime.new(@year, 12, 31), 2.weeks).report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@report), filename: "cycle_time_2_weekly_report_#{@deployment_constraint.name}.csv" }
      format.json { send_data @report.to_json }
    end
  end

  def four_week_overview
    boards = teams.map(&:board).compact
    @report = CycleTimeOverviewReportService.new(boards, DateTime.new(@year, 1, 1), DateTime.new(@year, 12, 31), 4.weeks).report

    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@report), filename: "cycle_time_4_weekly_report_#{@deployment_constraint.name}.csv" }
      format.json { send_data @report.to_json }
    end
  end

  private
  def set_deployment_constraint
    deployment_constraint_id = params[:deployment_constraint_id]
    @deployment_constraint = Repository.for(:deployment_constraint).find(deployment_constraint_id.to_i)
  end

  def set_department
    department_id = params[:department_id]
    @department = Repository.for(:department).find(department_id.to_i)
  end

  def teams
    if @department && @deployment_constraint
      @department.active_teams.select{ |team| team.deployment_constraint == @deployment_constraint }
    elsif @department
      @department.active_teams
    elsif @deployment_constraint
      @deployment_constraint.teams
    else
      []
    end
  end

  def set_years
    year = params[:year] || DateTime.now.year
    @year = year.to_i

    date = DateTime.now
    @years = [date.year]

    loop do
      date = date - 1.year
      @years << date.year

      break if date.year == 2019
    end
  end
end
