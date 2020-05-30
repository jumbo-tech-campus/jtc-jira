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

  def ==(team)
    self.board_id == team.board_id
  end

  def_delegator :@project, :avatars
  def_delegator :@project, :name, :project_name
  def_delegator :@project, :key, :project_key
end
