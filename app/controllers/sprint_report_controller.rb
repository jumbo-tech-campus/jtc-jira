class SprintReportController < ApplicationController
  before_action :set_board
  before_action :set_teams

  def last_sprint
    redirect_to action: 'sprint', board_id: @board.id, id: @board.last_closed_sprint.id
  end

  def sprint
    @sprint = Repository.for(:sprint).find_by(id: params[:id].to_i, board: @board)
  end

  private
  def set_board
    @board = Repository.for(:board).find(params[:board_id].to_i)
  end

  def set_teams
    @teams = Repository.for(:team).all
  end
end
