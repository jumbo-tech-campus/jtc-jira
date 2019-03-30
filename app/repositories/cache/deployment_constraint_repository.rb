module Cache
  class DeploymentConstraintRepository < Cache::CacheRepository
    def all
      @all ||= Repository.for(:team).all.inject([]) do |memo, team|
        memo << team.deployment_constraint unless memo.include?(team.deployment_constraint)
        memo
      end
    end

    def find(id)
      all.find{ |deployment_constraint| deployment_constraint.id == id }
    end
  end
end
