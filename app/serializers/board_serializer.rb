class BoardSerializer < ActiveModel::Serializer
  attributes :id

  has_one :team

  has_many :sprints
end
