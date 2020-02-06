class ParentEpic < ActiveModelSerializers::Model
  attr_reader :id, :key, :summary, :wbso_project, :assignee, :fix_versions, :epics, :status

  def initialize(id, key, summary, wbso_project, assignee, status)
    @id, @key, @summary, @wbso_project, @assignee, @status = id, key, summary, wbso_project, assignee, status
    @epics = []
    @fix_versions = []
  end

  def ==(parent_epic)
    self.key == parent_epic&.key
  end

  def description
    "#{key} - #{summary}"
  end
end
