class Project < ActiveModelSerializers::Model
  attr_reader :key, :name, :avatars

  def initialize(key, name, avatars)
    @key, @name, @avatars = key, name, avatars
  end
end
