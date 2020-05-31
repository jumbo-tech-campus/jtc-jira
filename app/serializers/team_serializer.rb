class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :board_id, :subteam, :archived_at, :started_at,
             :position, :component, :filter_sprints_by_team_name, :no_estimations

  has_one :department
  has_one :deployment_constraint
end
