class SprintReportController < AuthenticatedController
  before_action :set_team

  def sprint
    @sprint = if params[:id]
                Repository.for(:team_sprint).find_by(id: params[:id], team: @team)
              else
                @team.current_sprint || @team.last_closed_sprint
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
