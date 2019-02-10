class IssueSerializer < ActiveModel::Serializer
  attributes :id, :key, :summary, :estimation, :created, :resolution_date

  belongs_to :epic
  #has_many :sprint_change_events
end
