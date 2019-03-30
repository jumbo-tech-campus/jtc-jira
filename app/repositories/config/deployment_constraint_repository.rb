module Config
  class DeploymentConstraintRepository < Config::ConfigRepository
    def all
      @records ||= @client.get(:deployment_constraints).map do |config_hash|
        Factory.for(:deployment_constraint).create_from_hash(config_hash)
      end
    end

    def find(id)
      all.find{ |deployment_constraint| deployment_constraint.id == id }
    end
  end
end
