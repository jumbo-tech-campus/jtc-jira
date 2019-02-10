class SprintChangeEventSerializer < ActiveModel::Serializer
  attributes :id, :created
  belongs_to :to_sprint, serializer: SprintSerializer
  belongs_to :issue
end
