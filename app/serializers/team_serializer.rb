class TeamSerializer < ActiveModel::Serializer
  attributes :name, :board_id, :subteam

  has_one :department

  has_one :project
end
