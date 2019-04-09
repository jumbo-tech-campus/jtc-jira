class SprintReportController < ApplicationController
  before_action :set_board

  def last_sprint
    redirect_to action: 'sprint', board_id: @board.id, id: @board.last_closed_sprint.id
  end

  def sprint
    @sprint = Repository.for(:sprint).find_by(id: params[:id].to_i, board: @board)
  end

  def refresh_data
    CacheService.refresh_team_data(@board.team)
    redirect_to action: 'sprint', board_id: @board.id, id: @board.last_closed_sprint.id
  end

  private
  def set_board
    @board = Repository.for(:board).find(params[:board_id].to_i)
  end
end
