class DeploymentProjectSerializer < ActiveModel::Serializer
  attributes :key, :name, :avatars

  has_many :issues
end
