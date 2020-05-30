class Team < ActiveModelSerializers::Model
  extend Forwardable

  attr_reader :id, :name, :board_id, :subteam
  attr_accessor :project, :department, :deployment_constraint,
    :position, :archived_at, :started_at, :component, :filter_sprints_by_team_name

  def initialize(id, name, board_id, subteam)
    @id, @name, @board_id, @subteam = id, name, board_id, subteam
  end

  def is_scrum_team?
    board&.is_a? ScrumBoard
  end

  def board
    Repository.for(:board).find(board_id)
  end

  def issues
    board.issues
  end

  def issues_with_cycle_time
    @issues_with_cycle_time ||= issues.select(&:cycle_time).sort_by(&:release_date)
  end

  def issues_with_short_cycle_time
    @issues_with_short_cycle_time ||= issues.select(&:short_cycle_time).sort_by(&:pending_release_date)
  end

  def issues_with_cycle_time_delta
    @issues_with_cycle_time_delta ||= issues.select(&:cycle_time_delta).sort_by(&:release_date)
  end

  def sprints_from(year)
    board.sprints_from(year)
  end

  def current_sprint
    sprint_for(Date.today)
  end

  def sprint_for(date)
    board.sprint_for(date)
  end

  def last_closed_sprint
    board.last_closed_sprint
  end

  def is_active?(date = Date.today)
    if archived_at && archived_at <= date
      false
    elsif started_at && started_at > date
      false
    elsif deployment_constraint.id == 5
      false
    else
      true
    end
  end

  def is_active_in?(year)
    if archived_at && archived_at < Date.new(year, 1, 1)
      false
    elsif started_at && started_at > Date.new(year, 12, 31)
      false
    else
      true
    end
  end

  def has_position?
    position.present?
  end

  def is_scrum_team?
    board.is_a? ScrumBoard
  end

  def ==(team)
    self.board_id == team.board_id
  end

  def_delegator :@project, :avatars
  def_delegator :@project, :name, :project_name
  def_delegator :@project, :key, :project_key
end
