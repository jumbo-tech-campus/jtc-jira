class ParentEpic < ActiveModelSerializers::Model
  attr_reader :id, :key, :summary, :wbso_project, :fix_version 

  def initialize(id, key, summary, wbso_project, fix_version)
    @id, @key, @summary, @wbso_project, @fix_version = id, key, summary, wbso_project, fix_version
  end

  def ==(parent_epic)
    self.id == parent_epic.id
  end

  def description
    "#{key} - #{summary}"
  end
end
