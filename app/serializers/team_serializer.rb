class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :board_id, :subteam, :archived_at, :started_at,
    :position, :component, :filter_sprints_by_team_name

  has_one :department
  has_one :deployment_constraint
end
