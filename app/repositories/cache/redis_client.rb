require 'redis'

module Cache
  class RedisClient
    extend Forwardable

    def initialize
      if Rails.env.production?
        @client = Redis.new(url: "redis://#{ENV['REDIS_HOST']}", password: ENV['REDIS_PASSWORD'], ssl: true)
      else
        @client = Redis.new(host: ENV['REDIS_HOST'])
      end

      @statsd_client = StatsdClient.new
    end

    def get(key)
      started = Time.now
      result = "result:success"

      begin
        @client.get(key)
      rescue StandardError => e
        result = "result:failure"
        Rails.logger.error("Error in Redis get. \nRedis client: #{@client.inspect}\n#{e.backtrace}")
        raise
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
      rescue StandardError => e
        result = "result:failure"
        Rails.logger.error("Error in Redis get. \nRedis client: #{@client.inspect}\n#{e.backtrace}")
        raise
      ensure
        @statsd_client.timing('cache.duration',
          (Time.now - started) * 1000,
          tags: ["action:set", result, "key:#{key}"]
        )
      end
    end

    def_delegators :@client, :flushall, :dbsize
  end
end
