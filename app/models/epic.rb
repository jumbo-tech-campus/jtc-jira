class Epic
  attr_reader :key, :summary, :id, :name
  attr_accessor :parent_epic

  def initialize(key, summary, id, name)
    @key, @summary, @id, @name = key, summary, id, name
  end

  def self.from_jira(issue)
    epic = new(issue.key, issue.summary, issue.id.to_i, issue.fields['customfield_10018'])
    epic.parent_epic = ParentEpic.from_jira(issue.fields['customfield_11200']['data'])
    epic
  end

  def ==(epic)
    self.id == epic.id
  end

  def to_s
    "Epic: #{key} #{name}"
  end
end
