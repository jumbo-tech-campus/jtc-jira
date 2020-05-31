class ScrumBoardSerializer < ActiveModel::Serializer
  attributes :id, :type

  has_one :project
  has_one :team

  has_many :sprints
end
