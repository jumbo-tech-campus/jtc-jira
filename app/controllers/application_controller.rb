class ApplicationController < ActionController::Base
  before_action :set_teams

  private
  def set_teams
    @teams = Repository.for(:team).all
  end
end
