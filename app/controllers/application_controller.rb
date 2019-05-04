class ApplicationController < ActionController::Base
  before_action :set_teams
  before_action :set_departments

  private
  def set_teams
    @teams = Repository.for(:team).all.sort_by(&:name)
    @scrum_teams = @teams.select{ |team| team.is_scrum_team? }
  end

  def set_departments
    @departments = Repository.for(:department).all
  end
end
