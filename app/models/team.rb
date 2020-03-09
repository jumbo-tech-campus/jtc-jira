class Team < ActiveModelSerializers::Model
  extend Forwardable

  attr_reader :name, :board_id, :subteam
  attr_accessor :project, :department, :deployment_constraint, :position, :archived_at, :started_at

  def initialize(name, board_id, subteam)
    @name, @board_id, @subteam = name, board_id, subteam
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
