class ParentEpic < ActiveModelSerializers::Model
  attr_reader :id, :key, :summary, :wbso_project

  def initialize(id, key, summary, wbso_project)
    @id, @key, @summary, @wbso_project = id, key, summary, wbso_project
  end

  def ==(parent_epic)
    self.id == parent_epic.id
  end

  def description
    "#{key} - #{summary}"
  end
end
