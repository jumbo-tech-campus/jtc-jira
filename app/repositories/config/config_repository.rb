module Config
  class ConfigRepository
    def initialize(client)
      @client = client
      @records = {}
    end

    def all
      @client.get(config_key).map do |config_hash|
        unless @records[config_hash[:id]]
          @records[config_hash[:id]] = Factory.for(object_type).create_from_hash(config_hash)
        end
        @records[config_hash[:id]]
      end
    end

    def find(id)
      config = @client.get(config_key).find do |config_hash|
        config_hash[:id] == id
      end

      @records[id] ||= Factory.for(object_type).create_from_hash(config)
    end
  end
end
