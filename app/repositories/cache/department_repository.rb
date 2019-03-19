module Cache
  class DepartmentRepository < Cache::CacheRepository
    def all
      @all ||= Repository.for(:team).all.inject([]) do |memo, team|
        memo << team.department unless memo.include?(team.department)
        memo
      end
    end

    def find(id)
      all.find{ |department| department.id == id }
    end
  end
end
