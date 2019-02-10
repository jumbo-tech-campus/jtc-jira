require 'redis'

module Cache
  class RedisClient
    extend Forwardable

    def initialize
      @client = Redis.new(host: 'redis')
    end

    def_delegators :@client, :get, :set, :keys
  end
end
