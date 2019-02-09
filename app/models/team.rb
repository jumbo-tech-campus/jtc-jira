class Team
  extend Forwardable

  attr_reader :name, :board_id, :subteam
  attr_accessor :project

  def initialize(name, board_id, subteam)
    @name, @board_id, @subteam = name, board_id, subteam
  end

  def_delegator :@project, :avatars
  def_delegator :@project, :name, :project_name
  def_delegator :@project, :key, :project_key
end
