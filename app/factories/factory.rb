class Factory
  def self.register(type, factory)
    factories[type] = factory
  end

  def self.factories
    @factories ||= {}
  end

  def self.for(type)
    factories[type]
  end
end
