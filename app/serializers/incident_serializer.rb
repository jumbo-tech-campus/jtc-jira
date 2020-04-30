class IncidentSerializer < ActiveModel::Serializer
  attributes :id, :key, :summary, :estimation, :created, :status,
    :resolution_date, :in_progress_date, :release_date, :pending_release_date,
    :assignee, :resolution, :done_date, :labels, :class_name,
    :start_date, :end_date, :reported_date, :causes

  belongs_to :epic
end
