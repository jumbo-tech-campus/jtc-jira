class IssueSerializer < ActiveModel::Serializer
  attributes :id, :key, :summary, :estimation, :created, :status,
    :resolution_date, :in_progress_date, :release_date, :pending_release_date,
    :assignee, :resolution, :done_date

  belongs_to :epic
end
