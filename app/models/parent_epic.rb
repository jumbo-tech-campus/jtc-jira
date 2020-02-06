class ParentEpic < ActiveModelSerializers::Model
  attr_reader :id, :key, :summary, :wbso_project, :fix_version, :assignee, :epics, :status

  def initialize(id, key, summary, wbso_project, fix_version, assignee, status)
    @id, @key, @summary, @wbso_project, @fix_version, @assignee, @status = id, key, summary, wbso_project, fix_version, assignee, status
    @epics = []
  end

  def ==(parent_epic)
    self.key == parent_epic&.key
  end

  def description
    "#{key} - #{summary}"
  end
end
