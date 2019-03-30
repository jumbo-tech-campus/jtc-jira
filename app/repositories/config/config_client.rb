module Config
  class ConfigClient
    def initialize
      @config = YAML.load_file(Rails.root.join('config.yml'))
    end

    def get(key)
      @config[key]
    end
  end
end
