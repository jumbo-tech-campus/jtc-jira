module Config
  class DepartmentRepository < Config::ConfigRepository
    def config_key
      :departments
    end

    def object_type
      :department
    end
  end
end
