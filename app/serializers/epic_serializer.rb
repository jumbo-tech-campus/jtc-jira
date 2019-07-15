class EpicSerializer < ActiveModel::Serializer
  attributes :id, :key, :summary, :name, :status

  belongs_to :parent_epic
end
