class IssueSerializer < ActiveModel::Serializer
  attributes :id, :key, :summary, :estimation, :created, :status,
    :resolution_date, :in_progress_date, :release_date, :pending_release_date,
    :assignee, :resolution, :done_date, :labels, :class_name, :subteam,
    :components

  belongs_to :epic
end
