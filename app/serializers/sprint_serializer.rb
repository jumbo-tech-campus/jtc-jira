class SprintSerializer < ActiveModel::Serializer
  attributes :id, :name, :state, :start_date, :end_date, :complete_date

  attribute :board_id do
    object.board.id
  end

  has_many :issues
end
