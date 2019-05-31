class ParentEpicSerializer < ActiveModel::Serializer
  attributes :id, :key, :summary, :wbso_project, :fix_version
end
