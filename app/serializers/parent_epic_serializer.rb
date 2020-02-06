class ParentEpicSerializer < ActiveModel::Serializer
  attributes :id, :key, :summary, :wbso_project, :fix_versions, :assignee, :status

  has_many :epics
end
