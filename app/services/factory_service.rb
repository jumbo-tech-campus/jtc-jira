class FactoryService
  def self.register_factories
    Factory.register(:board, BoardFactory.new)
    Factory.register(:sprint, SprintFactory.new)
    Factory.register(:issue, IssueFactory.new)
    Factory.register(:epic, EpicFactory.new)
    Factory.register(:parent_epic, ParentEpicFactory.new)
    Factory.register(:project, ProjectFactory.new)
    Factory.register(:team, TeamFactory.new)
    Factory.register(:state_changed_event, StateChangedEventFactory.new)
    Factory.register(:department, DepartmentFactory.new)
  end
end
