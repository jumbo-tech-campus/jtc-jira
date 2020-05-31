class SprintReportController < ApplicationController
  before_action :set_team

  def sprint
    if params[:id]
      @sprint = TeamSprint.for(@team, Repository.for(:sprint).find_by(id: params[:id], team: @team))
    else
      @sprint = @team.current_sprint || @team.last_closed_sprint
    end
  end

  def refresh_data
    CacheService.refresh_team_data(@team)
    redirect_to action: 'sprint'
  end

  private
  def set_team
    @team = Repository.for(:team).find(params[:team_id].to_i)
  end
end
