class ApplicationController < ActionController::Base
  before_action :set_teams
  before_action :set_departments
  before_action :set_deployment_projects

  private
  def set_teams
    @teams = Repository.for(:team).all.sort_by(&:name)
    @scrum_teams = @teams.select{ |team| team.is_scrum_team? }
  end

  def set_departments
    @departments = Repository.for(:department).all
  end

  def set_deployment_projects
    @deployment_projects = Repository.for(:project).all.select{ |project| project.is_a? DeploymentProject }
  end
end
