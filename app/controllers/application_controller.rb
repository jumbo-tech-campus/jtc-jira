class ApplicationController < ActionController::Base
  before_action :set_teams

  private
  def set_teams
    @teams = Repository.for(:team).all
    @scrum_teams = @teams.select{ |team| team.is_scrum_team? }
  end
end
