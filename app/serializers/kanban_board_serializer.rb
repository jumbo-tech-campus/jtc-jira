class KanbanBoardSerializer < ActiveModel::Serializer
  attributes :id, :type

  has_one :team

  has_many :issues
end
