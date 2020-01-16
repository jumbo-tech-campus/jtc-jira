class Team < ActiveModelSerializers::Model
  extend Forwardable

  attr_reader :name, :board_id, :subteam
  attr_accessor :project, :department, :deployment_constraint

  def initialize(name, board_id, subteam)
    @name, @board_id, @subteam = name, board_id, subteam
  end

  def is_scrum_team?
    board&.is_a? ScrumBoard
  end

  def board
    Repository.for(:board).find(board_id)
  end

  def ==(team)
    self.board_id == team.board_id
  end

  def_delegator :@project, :avatars
  def_delegator :@project, :name, :project_name
  def_delegator :@project, :key, :project_key
end
