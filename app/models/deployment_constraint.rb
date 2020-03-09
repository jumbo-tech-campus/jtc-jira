class DeploymentConstraint < ActiveModelSerializers::Model
  attr_reader :id, :name

  def initialize(id, name)
    @id, @name = id, name
  end

  def teams
    @teams ||= Repository.for(:team).find_by(deployment_constraint_id: id).sort_by(&:name)
  end

  def active_teams_in(year = Date.today.year)
    teams.select{ |team| team.is_active_in?(year) }
  end

  def ==(deployment_constraint)
    self.id == deployment_constraint&.id
  end
end
