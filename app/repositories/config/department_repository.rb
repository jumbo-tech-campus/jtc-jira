module Config
  class DepartmentRepository < Config::ConfigRepository
    def all
      @records ||= @client.get(:departments).map do |config_hash|
        Factory.for(:department).create_from_hash(config_hash)
      end
    end

    def find(id)
      all.find{ |department| department.id == id }
    end
  end
end
