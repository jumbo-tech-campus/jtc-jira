module Config
  class TeamRepository < Config::ConfigRepository
    def all
      @records ||= @client.get(:teams).map do |config|
        Factory.for(:team).create_from_hash(config)
      end
    end

    def find_by(options)
      if options[:board_id]
        all.select{ |team| team.board_id == options[:board_id]}
      elsif options[:department_id]
        all.select{ |team| team.department.id == options[:department_id]}
      end
    end
  end
end
