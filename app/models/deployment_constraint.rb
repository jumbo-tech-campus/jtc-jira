class DeploymentConstraint < ActiveModelSerializers::Model
  attr_reader :id, :name

  def initialize(id, name)
    @id, @name = id, name
  end

  def teams
    @teams ||= Repository.for(:team).find_by(deployment_constraint_id: id)
  end

  def ==(deployment_constraint)
    self.id == deployment_constraint.id
  end
end
