module Cache
  class DeploymentConstraintRepository < Cache::CacheRepository
    def all
      @all ||= Repository.for(:team).all.map(&:deployment_constraint).uniq(&:id)
    end

    def find(id)
      all.find{ |deployment_constraint| deployment_constraint.id == id }
    end
  end
end
