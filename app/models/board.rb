class Board < ActiveModelSerializers::Model
  attr_reader :name, :id, :sprints
  attr_accessor :team

  def initialize(name, id)
    @name, @id = name, id
    @sprints = []
  end

  def closed_sprints
    sprints.select{ |sprint| sprint.closed? }
  end

  def open_sprint
    sprints.select{ |sprint| !sprint.closed? }.first
  end

  def recent_closed_sprints(n)
    closed_sprints.sort_by{ |sprint| sprint.end_date }.reverse.take(n)
  end

  def recent_sprints(n)
    sprints.sort_by{ |sprint| sprint.end_date }.reverse.take(n)
  end

  def last_closed_sprint
    recent_closed_sprints(1).first
  end

  def issues
    @issues ||= sprints.inject([]) do |memo, sprint|
      sprint.issues.each do |issue|
        memo << issue unless memo.include?(issue)
      end
      memo
    end
  end
end
