class IssueCollectionSerializer < ActiveModel::Serializer
  attributes :id, :name, :jira_filter

  has_many :issues
end
