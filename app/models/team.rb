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
    if is_scrum_team?
      @issues ||= filter_sprints(board.sprints).inject([]) do |memo, sprint|
        sprint.issues.each do |issue|
          memo << issue unless memo.include?(issue)
        end
        memo
      end
    else
      @issues ||= board.issues
    end
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
    filter_sprints(board.sprints_from(year))
  end

  def current_sprint
    sprint_for(Date.today)
  end

  def sprint_for(date)
    sprints = filter_sprints(board.sprints_for(date))
    sprints.first
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

  private
  def filter_sprints(sprints)
    if filter_sprints_by_team_name
      sprints.select { |sprint| sprint.name.downcase.include?(self.name.downcase) }
    else
      sprints
    end
  end
end
