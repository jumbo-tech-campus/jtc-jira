class StateChangedEvent
  attr_reader :created, :from_state, :to_state

  def initialize(created, from_state, to_state)
    @created, @from_state, @to_state = created, from_state, to_state
  end

  def to_s
    "Created on #{created} for state change from #{from_state} to #{to_state}"
  end  
end
