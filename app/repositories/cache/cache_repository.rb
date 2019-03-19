module Cache
  class CacheRepository
    def initialize(client)
      @client = client
      @records = {}
    end
  end
end
