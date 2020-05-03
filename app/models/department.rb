class Department < ActiveModelSerializers::Model
  attr_reader :id, :name

  def initialize(id, name)
    @id, @name = id, name
  end

  def teams
    @teams ||= Repository.for(:team).find_by(department_id: id).sort_by(&:name)
  end

  def active_teams(date = Date.today)
    teams.select{ |team| team.is_active?(date) }
  end

  def active_teams_in(year = Date.today.year)
    teams.select{ |team| team.is_active_in?(year) }
  end

  def scrum_teams
    teams.select(&:is_scrum_team?)
  end

  def active_scrum_teams(date = Date.today)
    active_teams(date).select(&:is_scrum_team?)
  end

  def boards
    teams.map(&:board).compact
  end

  def ==(department)
    self.id == department&.id
  end
end
