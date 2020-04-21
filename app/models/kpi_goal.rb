require 'securerandom'

class KpiGoal < ActiveModelSerializers::Model
  TYPES = {deployments: 'Deployments', releases: 'Released issues', cycle_time: 'Cycle time', p1s: 'P1 incidents'}

  attr_reader :id, :quarter, :department
  attr_accessor :metric, :type

  def initialize(id, quarter, department)
    @id, @quarter, @department = id, quarter, department
  end

  def quarter_id
    @quarter&.id
  end

  def department_id
    @department&.id
  end
end
