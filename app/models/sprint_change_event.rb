class SprintChangeEvent < ActiveModelSerializers::Model
  attr_reader :id, :created, :to_sprint, :issue

  def initialize(id, created, to_sprint, issue)
    @id, @created, @to_sprint, @issue = id, created, to_sprint, issue
  end

  def added_after_sprint_start?
    return false unless to_sprint.start_date

    self.created > to_sprint.start_date.end_of_day
  end

  def to_s
    puts "created #{self.created}, sprint start date #{to_sprint.start_date}, issue #{issue.key}"
  end
end
