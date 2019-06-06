class Department < ActiveModelSerializers::Model
  attr_reader :id, :name

  def initialize(id, name)
    @id, @name = id, name
  end

  def teams
    @teams ||= Repository.for(:team).find_by(department_id: id)
  end

  def scrum_teams
    teams.select(&:is_scrum_team?).sort_by(&:name)
  end

  def ==(department)
    self.id == department.id
  end
end
