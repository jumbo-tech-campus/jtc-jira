class KanbanBoardSerializer < ActiveModel::Serializer
  attributes :id, :type

  has_one :project

  has_many :issues
end
