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

  def open?
    !closed?
  end

  def issues
    @issues ||= Repository.for(:issue).find_by(sprint: self)
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

  def issue_estimation_nil_value
    0
  end
end
