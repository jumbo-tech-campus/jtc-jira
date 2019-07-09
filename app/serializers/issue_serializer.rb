class IssueSerializer < ActiveModel::Serializer
  attributes :id, :key, :summary, :estimation, :created, :status,
    :resolution_date, :in_progress_date, :done_date, :ready_for_prod_date,
    :assignee, :resolution

  belongs_to :epic
end
