class DeploymentConstraintFactory
  def create_from_hash(hash)
    DeploymentConstraint.new(hash[:id], hash[:name])
  end

  def create_from_json(json)
    DeploymentConstraint.new(json['id'], json['name'])
  end
end
