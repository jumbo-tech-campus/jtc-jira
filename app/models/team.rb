class Team < ActiveModelSerializers::Model
  extend Forwardable

  attr_reader :name, :board_id, :subteam
  attr_accessor :project

  def initialize(name, board_id, subteam)
    @name, @board_id, @subteam = name, board_id, subteam
  end

  def self.from_cache(json)
    team = new(json['name'], json['board_id'], json['subteam'])
    team.project = Project.from_cache(json['project'])
    team
  end

  def_delegator :@project, :avatars
  def_delegator :@project, :name, :project_name
  def_delegator :@project, :key, :project_key
end
