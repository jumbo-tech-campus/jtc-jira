class Sprint < ActiveModelSerializers::Model
  attr_reader :id, :name, :state, :start_date, :end_date, :complete_date
  attr_accessor :board

  include SprintIssueAbilities

  def initialize(id, name, state, start_date, end_date, complete_date)
    @id, @name, @state, @start_date, @end_date, @complete_date = id, name, state, start_date, end_date, complete_date

    sprint_issue_abilities(self, nil)
  end

  def closed?
    state == 'closed'
  end

  def issues
    @issues ||= Repository.for(:issue).find_by(sprint: self)
  end

  def percentage_closed
    return 0 if points_total == 0

    points_closed / sprint.points_total.to_f * 100
  end


  def sprint_epics
    return @sprint_epics if @sprint_epics

    no_sprint_epic = SprintEpic.new(self, Epic.new('DEV', 'Issues without epic', 0, 'Issues without epic'))

    @sprint_epics = issues.inject([]) do |memo, issue|
      if issue.epic
        sprint_epic = SprintEpic.new(self, issue.epic)
        if memo.include?(sprint_epic)
          sprint_epic = memo[memo.index(sprint_epic)]
        else
          memo << sprint_epic
        end
      else
        sprint_epic = no_sprint_epic
      end
      sprint_epic.issues << issue

      memo
    end

    @sprint_epics << no_sprint_epic if no_sprint_epic.issues.size > 0
    @sprint_epics
  end

  def sprint_parent_epics
    return @sprint_parent_epics if @sprint_parent_epics

    no_sprint_parent_epic = SprintParentEpic.new(self, ParentEpic.new(0, 'DEV', 'Issues without portfolio epic', nil, nil))

    @sprint_parent_epics = sprint_epics.inject([]) do |memo, sprint_epic|
      if sprint_epic.parent_epic
        sprint_parent_epic = SprintParentEpic.new(self, sprint_epic.parent_epic)
        if memo.include?(sprint_parent_epic)
          sprint_parent_epic = memo[memo.index(sprint_parent_epic)]
        else
          memo << sprint_parent_epic
        end
      else
        sprint_parent_epic = no_sprint_parent_epic
      end
      sprint_parent_epic.issues.concat(sprint_epic.issues)
      memo
    end

    @sprint_parent_epics << no_sprint_parent_epic if no_sprint_parent_epic.issues.size > 0
    @sprint_parent_epics
  end

  def done_issues
    @issues_done ||= @board.issues.inject([]) do |memo, issue|
      memo << issue if issue.done_date && issue.done_date.between?(self.start_date, self.complete_date || self.end_date)
      memo
    end
  end

  def average_cycle_time
    issues_with_cycle_time = done_issues.select(&:cycle_time)
    return nil if issues_with_cycle_time.size == 0

    total_cycle_time = issues_with_cycle_time.reduce(0){ |memo, issue| memo += issue.cycle_time }
    total_cycle_time / issues_with_cycle_time.size
  end

  def uid
    @uid ||= "#{board_id}_#{id}"
  end

  def board_id
    @board_id ||= board.id
  end

  def ==(sprint)
    self.uid == sprint.uid
  end
end
