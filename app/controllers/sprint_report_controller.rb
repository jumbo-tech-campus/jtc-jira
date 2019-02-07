class SprintReportController < ApplicationController
  def last_sprint
    board = Repository.for(:board).find_by(id: params[:board_id], subteam: params[:subteam])
    @sprint = board.last_closed_sprint
  end
end
