class User < ActiveModelSerializers::Model
  attr_reader :id, :name, :email, :provider
  attr_accessor :account_status

  def initialize(id, name, email, provider)
    @id, @name, @email, @provider = id, name, email, provider
  end
end
