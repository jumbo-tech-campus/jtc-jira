require 'redis'

module Cache
  class RedisClient
    extend Forwardable

    def initialize
      @client = if Rails.env.production?
                  Redis.new(host: ENV['REDIS_HOST'], password: ENV['REDIS_PASSWORD'], ssl: true, port: 6379, db: 0)
                else
                  Redis.new(host: ENV['REDIS_HOST'], db: 0)
                end
    end

    def get(key)
      @client.get(key)
    rescue StandardError => e
      Rails.logger.error("Error in Redis get. \nRedis client: #{@client.inspect}\n#{e.backtrace}")
      raise
    end

    def set(key, value)
      @client.set(key, value)
    rescue StandardError => e
      Rails.logger.error("Error in Redis get. \nRedis client: #{@client.inspect}\n#{e.backtrace}")
      raise
    end

    def_delegators :@client, :dbsize, :del, :keys
  end
end
