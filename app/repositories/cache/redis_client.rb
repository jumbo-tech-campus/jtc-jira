require 'redis'

module Cache
  class RedisClient
    extend Forwardable

    def initialize
      @client = Redis.new(host: ENV['REDIS_HOST'])
    end

    def_delegators :@client, :get, :set, :keys
  end
end
