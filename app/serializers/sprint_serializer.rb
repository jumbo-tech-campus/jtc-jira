class SprintSerializer < ActiveModel::Serializer
  attributes :id, :name, :state, :start_date, :end_date, :complete_date, :board_id

  has_many :issues
end
