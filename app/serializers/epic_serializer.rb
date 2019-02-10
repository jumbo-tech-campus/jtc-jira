class EpicSerializer < ActiveModel::Serializer
  attributes :id, :key, :summary, :name

  belongs_to :parent_epic
end
