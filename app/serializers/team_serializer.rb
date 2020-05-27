class TeamSerializer < ActiveModel::Serializer
  attributes :name, :board_id, :subteam, :archived_at, :started_at, :position, :component

  has_one :department
  has_one :deployment_constraint
  has_one :project
end
