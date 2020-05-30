class SprintReportController < ApplicationController
  before_action :set_board

  def sprint
    if params[:id]
      @sprint = Repository.for(:sprint).find_by(id: params[:id], board: @team.board)
    else
      @sprint = @team.board.current_sprint || @team.board.last_closed_sprint
    end
  end

  def refresh_data
    CacheService.refresh_team_data(@team)
    redirect_to action: 'sprint'
  end

  private
  def set_board
    @team = Repository.for(:team).find(params[:team_id].to_i)
  end
end
