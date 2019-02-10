class BoardSerializer < ActiveModel::Serializer
  attributes :id, :name

  has_one :team

  has_many :sprints
end
