module Cache
  class UserRepository < Cache::CacheRepository
    def find(id)
      return @records[id] if @records[id]

      json = @client.get("user.#{id}")

      if json
        @records[id] = Factory.for(:user).create_from_json(JSON.parse(json))
      end
    end

    def save(user)
      @client.set("user.#{user.id}", ActiveModelSerializers::SerializableResource.new(user).to_json)
    end

    def delete(user)
      @client.del("user.#{user.id}")
    end

    def all
      @client.keys('user.*').map { |id| find(id.sub('user.', '')) }
    end
  end
end
