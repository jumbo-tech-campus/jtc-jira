module Config
  class DeploymentConstraintRepository < Config::ConfigRepository
    def config_key
      :deployment_constraints
    end

    def object_type
      :deployment_constraint
    end
  end
end
