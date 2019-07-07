module Config
  class QuarterRepository < Config::ConfigRepository
    def config_key
      :quarters
    end

    def object_type
      :quarter
    end

    def all
      @client.get(config_key).map do |config_hash|
        Factory.for(object_type).create_from_hash(config_hash)
      end
    end
  end
end
