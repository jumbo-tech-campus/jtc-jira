class IssueSerializer < ActiveModel::Serializer
  attributes :id, :key, :summary, :estimation, :created, :resolution_date

  belongs_to :epic
end
