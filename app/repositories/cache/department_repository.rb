module Cache
  class DepartmentRepository < Cache::CacheRepository
    def all
      @all ||= Repository.for(:team).all.map(&:department).uniq(&:id)
    end

    def find(id)
      all.find { |department| department.id == id }
    end
  end
end
