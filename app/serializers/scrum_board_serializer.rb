class ScrumBoardSerializer < ActiveModel::Serializer
  attributes :id, :type

  has_one :project

  has_many :sprints
end
