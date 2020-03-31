require 'redis'

module Cache
  class RedisClient
    extend Forwardable

    def initialize
      if Rails.env.production?
        @client = Redis.new(host: ENV['REDIS_HOST'], password: ENV['REDIS_PASSWORD'], ssl: true, port: 6379, db: 0)
      else
        @client = Redis.new(host: ENV['REDIS_HOST'], db: 0)
      end
    end

    def get(key)
      begin
        @client.get(key)
      rescue StandardError => e
        Rails.logger.error("Error in Redis get. \nRedis client: #{@client.inspect}\n#{e.backtrace}")
        raise
      end
    end

    def set(key, value)
      begin
        @client.set(key, value)
      rescue StandardError => e
        Rails.logger.error("Error in Redis get. \nRedis client: #{@client.inspect}\n#{e.backtrace}")
        raise
      end
    end

    def_delegators :@client, :flushall, :dbsize, :del
  end
end
