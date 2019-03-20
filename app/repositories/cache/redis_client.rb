require 'redis'

module Cache
  class RedisClient
    extend Forwardable

    def initialize
      @client = Redis.new(host: ENV['REDIS_HOST'])
      @statsd_client = StatsdClient.new
    end

    def get(key)
      started = Time.now
      result = "result:success"

      begin
        @client.get(key)
      rescue
        result = "result:failure"
      ensure
        @statsd_client.timing('cache.duration',
          (Time.now - started) * 1000,
          tags: ["action:get", result, "key:#{key}"]
        )
      end
    end

    def set(key, value)
      started = Time.now
      result = "result:success"

      begin
        @client.set(key, value)
      rescue
        result = "result:failure"
      ensure
        @statsd_client.timing('cache.duration',
          (Time.now - started) * 1000,
          tags: ["action:set", result, "key:#{key}"]
        )
      end
    end
  end
end
